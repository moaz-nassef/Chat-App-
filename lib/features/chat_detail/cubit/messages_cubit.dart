import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/ai_constants.dart';
import '../../../core/errors/failure.dart';
import '../../ai_chat/data/ai_repo.dart';
import '../data/message_model.dart';
import '../data/message_repo.dart';
import 'messages_state.dart';

/// Owns one open conversation: the messages stream, sending,
/// read receipts, and the AI assistant round-trip.
class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit(this._messageRepo, this._aiRepo)
    : super(const MessagesInitial());

  final MessageRepo _messageRepo;
  final AiRepo _aiRepo;

  StreamSubscription<List<MessageModel>>? _messagesSub;

  String _chatId = '';
  String _myUid = '';
  String _receiverId = '';

  bool get _isAiChat => _receiverId == AiConstants.aiUserId;

  MessagesLoaded? get _loaded =>
      state is MessagesLoaded ? state as MessagesLoaded : null;

  /// Opens the conversation: subscribes to the stream and keeps
  /// read receipts in sync while the screen is visible.
  void openChat({
    required String chatId,
    required String myUid,
    required String receiverId,
  }) {
    _chatId = chatId;
    _myUid = myUid;
    _receiverId = receiverId;

    emit(const MessagesLoading());
    _messagesSub?.cancel();

    _messagesSub = _messageRepo.watchMessages(chatId).listen((messages) {
      final current = _loaded;
      emit(
        MessagesLoaded(
          messages: messages,
          isAiTyping: current?.isAiTyping ?? false,
        ),
      );
      // Screen is open → everything incoming is immediately "read".
      _messageRepo.markAllAsRead(chatId: chatId, currentUid: myUid);
    }, onError: (Object e) => emit(MessagesError(e.toString())));
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final current = _loaded;
    emit(
      (current ?? const MessagesLoaded(messages: [])).copyWith(
        isSending: true,
        clearActionError: true,
      ),
    );

    try {
      await _messageRepo.sendMessage(
        chatId: _chatId,
        senderId: _myUid,
        receiverId: _receiverId,
        text: text,
      );
    } on Failure catch (f) {
      _emitActionError('تعذر إرسال الرسالة: ${f.message}');
      return;
    } finally {
      final after = _loaded;
      if (after != null && !isClosed) emit(after.copyWith(isSending: false));
    }

    if (_isAiChat) unawaited(_respondWithAi(text));
  }

  Future<void> _respondWithAi(String userPrompt) async {
    final before = _loaded;
    if (before != null && !isClosed) {
      emit(before.copyWith(isAiTyping: true));
    }

    try {
      final aiText = await _aiRepo.ask(chatId: _chatId, prompt: userPrompt);
      // Firestore rules allow senderId == ai_agent when it's a participant.
      await _messageRepo.sendMessage(
        chatId: _chatId,
        senderId: AiConstants.aiUserId,
        receiverId: _myUid,
        text: aiText,
        type: AiConstants.messageTypeAi,
      );
    } on Failure catch (f) {
      _emitActionError(f.message);
    } catch (e) {
      // Safety net: never let an unexpected error escape this
      // unawaited future silently — show it to the user instead.
      _emitActionError('❌ خطأ غير متوقع في المساعد الذكي: $e');
    } finally {
      final after = _loaded;
      if (after != null && !isClosed) {
        emit(after.copyWith(isAiTyping: false));
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _messageRepo.deleteMessage(chatId: _chatId, messageId: messageId);
    } on Failure catch (f) {
      _emitActionError('تعذر حذف الرسالة: ${f.message}');
    }
  }

  /// Called by the view after the error SnackBar is shown.
  void clearActionError() {
    final current = _loaded;
    if (current != null && !isClosed) {
      emit(current.copyWith(clearActionError: true));
    }
  }

  void _emitActionError(String message) {
    final current = _loadedOrEmpty();
    if (!isClosed) emit(current.copyWith(actionError: message));
  }

  MessagesLoaded _loadedOrEmpty() =>
      _loaded ?? const MessagesLoaded(messages: []);

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
