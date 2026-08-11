import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/errors/failure.dart';
import '../data/call_model.dart';
import '../data/call_repo.dart';
import '../data/permission_service.dart';
import '../data/webrtc_service.dart';
import 'call_state.dart';

/// App-wide controller for one active audio call and its Firestore signalling.
class CallCubit extends Cubit<CallState> {
  CallCubit(this._repo, this._permissions, this._webRtc)
    : super(const CallIdle());

  final CallRepo _repo;
  final PermissionService _permissions;
  final WebRtcService _webRtc;

  StreamSubscription<CallModel?>? _callSubscription;
  StreamSubscription<List<Map<String, Object?>>>? _candidatesSubscription;
  StreamSubscription<List<CallModel>>? _incomingSubscription;

  /// Call ID currently being managed (incoming or outgoing).
  String? _activeCallId;

  /// True when this device initiated the call.
  bool _isCaller = false;

  /// Prevents double-applying the remote answer.
  bool _answerApplied = false;

  bool get hasActiveCall => _activeCallId != null;

  // ─── Start outgoing call ─────────────────────────────────────────

  Future<CallModel?> startCall({
    required String callerId,
    required String callerName,
    required String? callerPhotoUrl,
    required String receiverId,
  }) async {
    if (hasActiveCall) return null;
    String? callId;
    try {
      await _permissions.ensureMicrophoneAccess();

      callId = await _repo.createCall(
        callerId: callerId,
        callerName: callerName,
        callerPhotoUrl: callerPhotoUrl,
        receiverId: receiverId,
      );

      _activeCallId = callId;
      _isCaller = true;

      await _webRtc.initializePeerConnection(
        onLocalCandidate: (candidate) =>
            _publishCandidate(callId!, true, candidate),
      );

      final offer = await _webRtc.createOffer();
      await _repo.publishOffer(
        callId: callId,
        type: offer.type!,
        sdp: offer.sdp!,
      );

      _watchCall(callId);
      emit(
        CallOutgoing(
          CallModel(
            id: callId,
            callerId: callerId,
            callerName: callerName,
            callerPhotoUrl: callerPhotoUrl,
            receiverId: receiverId,
            status: CallStatus.ringing,
            createdAt: DateTime.now(),
          ),
        ),
      );
      return CallModel(
        id: callId,
        callerId: callerId,
        callerName: callerName,
        callerPhotoUrl: callerPhotoUrl,
        receiverId: receiverId,
        status: CallStatus.ringing,
        createdAt: DateTime.now(),
      );
    } on Failure catch (failure) {
      if (callId != null) await _safeDelete(callId);
      await _localCleanup();
      emit(CallFailure(failure.message));
    } catch (_) {
      if (callId != null) await _safeDelete(callId);
      await _localCleanup();
      emit(const CallFailure('تعذر بدء المكالمة. تأكد من اتصالك والميكروفون.'));
    }
    return null;
  }

  // ─── Accept incoming call ────────────────────────────────────────

  Future<bool> acceptCall() async {
    final incoming =
        state is CallIncoming ? (state as CallIncoming).call : null;
    if (incoming == null) return false;
    try {
      await _permissions.ensureMicrophoneAccess();
      _activeCallId = incoming.id;
      _isCaller = false;
      emit(CallConnecting(incoming));

      final offer = await _repo.getOffer(incoming.id);
      await _webRtc.initializePeerConnection(
        onLocalCandidate: (candidate) =>
            _publishCandidate(incoming.id, false, candidate),
      );

      final answer = await _webRtc.createAnswer(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      await _repo.publishAnswer(
        callId: incoming.id,
        type: answer.type!,
        sdp: answer.sdp!,
      );

      _watchCall(incoming.id);
      _watchRemoteCandidates(incoming.id);
      emit(CallConnected(incoming));
      return true;
    } on Failure catch (failure) {
      await _safeDelete(incoming.id);
      await _localCleanup();
      emit(CallFailure(failure.message));
    } catch (_) {
      await _safeDelete(incoming.id);
      await _localCleanup();
      emit(const CallFailure('تعذر قبول المكالمة.'));
    }
    return false;
  }

  // ─── Decline / End call ──────────────────────────────────────────

  Future<void> declineCall() async {
    final callId = _activeCallId ?? _callFromState()?.id;
    if (callId == null) return;

    try {
      // Receiver sets status to ended so the caller gets notified.
      await _repo.endCall(callId);
    } catch (_) {}

    await _localCleanup();
    if (!isClosed) emit(const CallIdle());
  }

  Future<void> endCall() async {
    final callId = _activeCallId ?? _callFromState()?.id;
    try {
      if (callId != null) await _repo.endCall(callId);
    } catch (_) {
      // Device resources must be released even if the network is unavailable.
    } finally {
      await _localCleanup();
      if (!isClosed) emit(const CallIdle());
    }
  }

  // ─── Controls ────────────────────────────────────────────────────

  void toggleMute() {
    final call = _callFromState();
    if (call == null) return;
    _webRtc.toggleMute();
    _emitActiveCall(call);
  }

  void toggleSpeaker() {
    final call = _callFromState();
    if (call == null) return;
    _webRtc.toggleSpeaker();
    _emitActiveCall(call);
  }

  // ─── Incoming call listener ─────────────────────────────────────

  void watchIncomingCalls(String uid) {
    _incomingSubscription?.cancel();
    _incomingSubscription = _repo.watchIncomingCalls(uid).listen((calls) {
      if (hasActiveCall || calls.isEmpty || isClosed) return;
      final call = calls.first;
      _activeCallId = call.id;
      _isCaller = false;
      _watchCall(call.id);
      emit(CallIncoming(call));
    }, onError: (_) {});
  }

  Future<void> stopIncomingCalls() async {
    await _incomingSubscription?.cancel();
    _incomingSubscription = null;
    if (hasActiveCall) await endCall();
  }

  // ─── Internal: watch call document ──────────────────────────────

  void _watchCall(String callId) {
    _callSubscription?.cancel();
    _callSubscription = _repo.watchCall(callId).listen((call) async {
      if (call == null || call.status == CallStatus.ended) {
        await _localCleanup();
        if (!isClosed) emit(const CallIdle());
        return;
      }

      // Only the caller applies the remote answer.
      if (_isCaller &&
          call.status == CallStatus.connected &&
          !_answerApplied) {
        _answerApplied = true;
        try {
          final answer = await _repo.getAnswer(callId);
          await _webRtc.setRemoteAnswer(
            RTCSessionDescription(answer['sdp'], answer['type']),
          );
          _watchRemoteCandidates(callId);
          if (!isClosed) emit(CallConnected(call));
        } catch (_) {
          await endCall();
        }
      }
    }, onError: (_) {});
  }

  // ─── Internal: watch remote ICE candidates ──────────────────────

  void _watchRemoteCandidates(String callId) {
    _candidatesSubscription?.cancel();
    _candidatesSubscription = _repo
        .watchRemoteCandidates(callId: callId, isCaller: _isCaller)
        .listen((candidates) {
      for (final candidate in candidates) {
        unawaited(_webRtc.addRemoteCandidate(candidate));
      }
    }, onError: (_) {});
  }

  // ─── Internal: publish local ICE candidate ──────────────────────

  Future<void> _publishCandidate(
    String callId,
    bool fromCaller,
    RTCIceCandidate candidate,
  ) async {
    final rawCandidate = candidate.candidate;
    if (rawCandidate == null) return;
    try {
      await _repo.addCandidate(
        callId: callId,
        fromCaller: fromCaller,
        candidate: rawCandidate,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
      );
    } catch (_) {}
  }

  // ─── Internal helpers ────────────────────────────────────────────

  /// Deletes the call doc + candidates (best-effort, never throws).
  Future<void> _safeDelete(String callId) async {
    try {
      await _repo.deleteCall(callId);
    } catch (_) {}
  }

  CallModel? _callFromState() => switch (state) {
    CallOutgoing(:final call) ||
    CallIncoming(:final call) ||
    CallConnecting(:final call) ||
    CallConnected(:final call) => call,
    _ => null,
  };

  void _emitActiveCall(CallModel call) {
    final muted = _webRtc.isMuted;
    final speaker = _webRtc.isSpeakerOn;
    if (state is CallConnected) {
      emit(CallConnected(call, isMuted: muted, isSpeakerOn: speaker));
    } else if (state is CallConnecting) {
      emit(CallConnecting(call, isMuted: muted, isSpeakerOn: speaker));
    } else if (state is CallOutgoing) {
      emit(CallOutgoing(call, isMuted: muted, isSpeakerOn: speaker));
    }
  }

  Future<void> _localCleanup() async {
    await _callSubscription?.cancel();
    _callSubscription = null;
    await _candidatesSubscription?.cancel();
    _candidatesSubscription = null;
    _activeCallId = null;
    _isCaller = false;
    _answerApplied = false;
    await _webRtc.dispose();
  }

  @override
  Future<void> close() async {
    await stopIncomingCalls();
    return super.close();
  }
}
