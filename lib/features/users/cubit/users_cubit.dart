import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../auth/data/user_model.dart';
import '../../chats/data/chat_repo.dart';
import '../data/users_repo.dart';
import 'users_state.dart';

/// Users directory: real-time list + search + "start chat" action.
class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._usersRepo, this._chatRepo) : super(const UsersInitial());

  final UsersRepo _usersRepo;
  final ChatRepo _chatRepo;

  StreamSubscription<List<UserModel>>? _sub;

  List<UserModel> _users = const [];
  String _query = '';
  bool _usersArrived = false;

  void watchUsers(String currentUid) {
    emit(const UsersLoading());
    _sub?.cancel();
    _usersArrived = false;

    _sub = _usersRepo.watchUsers().listen((users) {
      _users = users.where((u) => u.uid != currentUid).toList();
      _usersArrived = true;
      _emitLoaded();
    }, onError: (Object e) => emit(UsersError(e.toString())));
  }

  void setSearchQuery(String query) {
    _query = query;
    _emitLoaded();
  }

  /// Creates (or reuses) the 1:1 room then emits [UsersChatReady]
  /// so the view can navigate.
  Future<void> startChatWith({
    required String currentUid,
    required String currentEmail,
    required UserModel otherUser,
  }) async {
    final current = state is UsersLoaded ? state as UsersLoaded : null;
    if (current == null) return;

    emit(current.copyWith(isCreatingChat: true));
    try {
      final chatId = await _chatRepo.createOrGetChat(
        currentUid: currentUid,
        otherUid: otherUser.uid,
        currentEmail: currentEmail,
        otherEmail: otherUser.email,
      );
      if (isClosed) return;
      emit(
        UsersChatReady(
          chatId: chatId,
          otherUser: otherUser,
          previous: current.copyWith(isCreatingChat: false),
        ),
      );
      // Restore the list state so coming back shows it correctly.
      emit(current.copyWith(isCreatingChat: false));
    } on Failure catch (f) {
      if (isClosed) return;
      emit(UsersError(f.message));
      emit(current.copyWith(isCreatingChat: false));
    }
  }

  void _emitLoaded() {
    if (!_usersArrived || isClosed) return;
    final current = state is UsersLoaded ? state as UsersLoaded : null;
    emit(
      UsersLoaded(
        users: _users,
        searchQuery: _query,
        isCreatingChat: current?.isCreatingChat ?? false,
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
