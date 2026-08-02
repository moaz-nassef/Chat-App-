import 'package:equatable/equatable.dart';

import '../../../core/constants/ai_constants.dart';
import '../../auth/data/user_model.dart';
import '../data/chat_model.dart';

sealed class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

final class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

final class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

/// Chats stream + users directory (for names/avatars/online) + search.
final class ChatsLoaded extends ChatsState {
  const ChatsLoaded({
    required this.chats,
    required this.usersById,
    this.searchQuery = '',
  });

  final List<ChatModel> chats;
  final Map<String, UserModel> usersById;
  final String searchQuery;

  /// Non-AI chats matching the current search query.
  List<ChatModel> visibleChats(String currentUid, String aiUserId) {
    final private =
        chats.where((c) => !c.participants.contains(aiUserId)).toList();
    if (searchQuery.isEmpty) return private;

    return private.where((chat) {
      final otherId = chat.otherParticipantId(currentUid);
      final other = usersById[otherId];
      final q = searchQuery.toLowerCase();
      return (other?.displayName.toLowerCase().contains(q) ?? false) ||
          (other?.email.toLowerCase().contains(q) ?? false) ||
          chat.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  /// The AI room if it already exists.
  ChatModel? aiChat(String aiUserId) {
    for (final chat in chats) {
      if (chat.participants.contains(aiUserId)) return chat;
    }
    return null;
  }

  /// Whether the pinned AI tile matches the current search query.
  bool get aiVisible {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    final ai = aiChat(AiConstants.aiUserId);
    return AiConstants.aiDisplayName.toLowerCase().contains(q) ||
        AiConstants.aiEmail.toLowerCase().contains(q) ||
        (ai?.lastMessage.toLowerCase().contains(q) ?? false);
  }

  ChatsLoaded copyWith({
    List<ChatModel>? chats,
    Map<String, UserModel>? usersById,
    String? searchQuery,
  }) {
    return ChatsLoaded(
      chats: chats ?? this.chats,
      usersById: usersById ?? this.usersById,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [chats, usersById, searchQuery];
}

/// Stream failure (initial load).
final class ChatsError extends ChatsState {
  const ChatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
