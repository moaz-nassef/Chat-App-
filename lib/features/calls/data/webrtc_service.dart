import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Owns device audio and a single active WebRTC peer connection.
class WebRtcService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isSpeakerOn = false;

  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;

  Future<void> prepareLocalAudio() async {
    if (_localStream != null) return;
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    await session.setActive(true);
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'mandatory': {
          'googEchoCancellation': 'true',
          'googAutoGainControl': 'true',
          'googNoiseSuppression': 'true',
        },
        'optional': [],
      },
      'video': false,
    });
  }

  Future<void> initializePeerConnection({
    required Future<void> Function(RTCIceCandidate candidate) onLocalCandidate,
  }) async {
    await prepareLocalAudio();
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    });
    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) unawaited(onLocalCandidate(candidate));
    };
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
    await _peerConnection!.setRemoteDescription(offer);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteAnswer(RTCSessionDescription answer) =>
      _peerConnection!.setRemoteDescription(answer);

  Future<void> addRemoteCandidate(Map<String, Object?> data) async {
    final candidate = data['candidate'] as String?;
    if (candidate == null) return;
    await _peerConnection?.addCandidate(
      RTCIceCandidate(
        candidate,
        data['sdpMid'] as String?,
        data['sdpMLineIndex'] as int?,
      ),
    );
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    for (final track in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_isMuted;
    }
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    Helper.setSpeakerphoneOn(_isSpeakerOn);
  }

  Future<void> dispose() async {
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      track.stop();
    }
    await _localStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _isMuted = false;
    _isSpeakerOn = false;
    await (await AudioSession.instance).setActive(false);
  }
}
