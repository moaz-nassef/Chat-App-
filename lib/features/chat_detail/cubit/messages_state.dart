import 'package:equatable/equatable.dart';

import '../data/message_model.dart';

sealed class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

final class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

final class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

/// Messages (newest first) + transient UI flags.
final class MessagesLoaded extends MessagesState {
  const MessagesLoaded({
    required this.messages,
    this.isAiTyping = false,
    this.isSending = false,
    this.actionError,
  });

  final List<MessageModel> messages;
  final bool isAiTyping;
  final bool isSending;

  /// One-shot error for actions (send/delete) — consumed by a BlocListener.
  final String? actionError;

  MessagesLoaded copyWith({
    List<MessageModel>? messages,
    bool? isAiTyping,
    bool? isSending,
    String? actionError,
    bool clearActionError = false,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      isSending: isSending ?? this.isSending,
      actionError: clearActionError ? null : actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [messages, isAiTyping, isSending, actionError];
}

/// Initial stream failure.
final class MessagesError extends MessagesState {
  const MessagesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
