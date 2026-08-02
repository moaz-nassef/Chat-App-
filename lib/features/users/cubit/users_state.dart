import 'package:equatable/equatable.dart';

import '../../auth/data/user_model.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

final class UsersInitial extends UsersState {
  const UsersInitial();
}

final class UsersLoading extends UsersState {
  const UsersLoading();
}

final class UsersLoaded extends UsersState {
  const UsersLoaded({
    required this.users,
    this.searchQuery = '',
    this.isCreatingChat = false,
  });

  /// All users except me (unfiltered).
  final List<UserModel> users;
  final String searchQuery;

  /// True while createOrGetChat is running (tile shows a spinner).
  final bool isCreatingChat;

  /// Users matching the search query (name or email).
  List<UserModel> get filtered {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users
        .where(
          (u) =>
              u.displayName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  UsersLoaded copyWith({
    List<UserModel>? users,
    String? searchQuery,
    bool? isCreatingChat,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      isCreatingChat: isCreatingChat ?? this.isCreatingChat,
    );
  }

  @override
  List<Object?> get props => [users, searchQuery, isCreatingChat];
}

/// One-shot navigation event: chat room ready → open it.
final class UsersChatReady extends UsersState {
  const UsersChatReady({
    required this.chatId,
    required this.otherUser,
    required this.previous,
  });

  final String chatId;
  final UserModel otherUser;

  /// The list state to restore right after navigating.
  final UsersLoaded previous;

  @override
  List<Object?> get props => [chatId, otherUser, previous];
}

final class UsersError extends UsersState {
  const UsersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
