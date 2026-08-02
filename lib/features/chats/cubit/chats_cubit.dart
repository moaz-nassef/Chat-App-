import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/user_model.dart';
import '../../users/data/users_repo.dart';
import '../data/chat_model.dart';
import '../data/chat_repo.dart';
import 'chats_state.dart';

/// Watches my chats + the users directory together and merges them
/// into a single [ChatsLoaded] state (no cubit→cubit dependency —
/// everything comes from repos).
class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit(this._chatRepo, this._usersRepo) : super(const ChatsInitial());

  final ChatRepo _chatRepo;
  final UsersRepo _usersRepo;

  StreamSubscription<List<ChatModel>>? _chatsSub;
  StreamSubscription<List<UserModel>>? _usersSub;

  List<ChatModel> _chats = const [];
  Map<String, UserModel> _usersById = const {};
  String _query = '';
  bool _chatsArrived = false;

  /// Starts both streams. Call once per screen (view passes the uid —
  /// the cubit never depends on AuthCubit).
  void watchChats(String currentUid) {
    emit(const ChatsLoading());

    _chatsSub?.cancel();
    _usersSub?.cancel();
    _chatsArrived = false;

    _chatsSub = _chatRepo.watchMyChats(currentUid).listen((chats) {
      _chats = chats;
      _chatsArrived = true;
      _emitLoaded();
    }, onError: (Object e) => emit(ChatsError(e.toString())));

    // Users directory: resolves names/avatars/online for chat tiles.
    // Non-fatal — tiles fall back to the raw uid if it's missing.
    _usersSub = _usersRepo.watchUsers().listen((users) {
      _usersById = {for (final user in users) user.uid: user};
      _emitLoaded();
    }, onError: (_) {});
  }

  void setSearchQuery(String query) {
    _query = query;
    _emitLoaded();
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRepo.deleteChat(chatId);
    } catch (e) {
      emit(ChatsError(e.toString()));
      _emitLoaded(); // restore the list state after showing the error
    }
  }

  Future<String> createOrGetChat({
    required String currentUid,
    required String otherUid,
    required String currentEmail,
    required String otherEmail,
  }) {
    return _chatRepo.createOrGetChat(
      currentUid: currentUid,
      otherUid: otherUid,
      currentEmail: currentEmail,
      otherEmail: otherEmail,
    );
  }

  void _emitLoaded() {
    if (!_chatsArrived) return; // wait for the chats stream at least once
    if (isClosed) return;
    emit(
      ChatsLoaded(chats: _chats, usersById: _usersById, searchQuery: _query),
    );
  }

  @override
  Future<void> close() {
    _chatsSub?.cancel();
    _usersSub?.cancel();
    return super.close();
  }
}
