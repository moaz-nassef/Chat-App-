import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/ai_chat/cubit/ai_settings_cubit.dart';
import '../features/ai_chat/data/ai_repo.dart';
import '../features/ai_chat/data/ai_settings_store.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/data/auth_datasource.dart';
import '../features/auth/data/auth_repo.dart';
import '../features/chat_detail/cubit/messages_cubit.dart';
import '../features/chat_detail/data/message_datasource.dart';
import '../features/chat_detail/data/message_repo.dart';
import '../features/chats/cubit/chats_cubit.dart';
import '../features/chats/data/chat_datasource.dart';
import '../features/chats/data/chat_repo.dart';
import '../features/calls/cubit/call_cubit.dart';
import '../features/calls/data/call_datasource.dart';
import '../features/calls/data/call_repo.dart';
import '../features/calls/data/permission_service.dart';
import '../features/calls/data/webrtc_service.dart';
import '../features/users/cubit/users_cubit.dart';
import '../features/users/data/users_datasource.dart';
import '../features/users/data/users_repo.dart';
import 'services/presence_service.dart';

/// Service locator. `sl` = the single GetIt instance.
final sl = GetIt.instance;

/// Registers every dependency. Call once in `main()` before runApp.
///
/// - DataSources / Repos / Services → **lazy singletons** (one instance
///   for the whole app lifetime)
/// - AuthCubit → **singleton** (app-lifetime session)
/// - Screen cubits → **factories** (fresh instance per screen)
Future<void> initDependencies() async {
  // ─── DataSources ───────────────────────────────────────────────
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource());
  sl.registerLazySingleton<UsersDataSource>(() => UsersDataSource());
  sl.registerLazySingleton<ChatDataSource>(() => ChatDataSource());
  sl.registerLazySingleton<MessageDataSource>(() => MessageDataSource());
  sl.registerLazySingleton<CallDataSource>(
    () => CallDataSource(FirebaseFirestore.instance),
  );

  // ─── Repos ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepo>(() => AuthRepo(sl(), sl()));
  sl.registerLazySingleton<UsersRepo>(() => UsersRepo(sl()));
  sl.registerLazySingleton<ChatRepo>(() => ChatRepo(sl()));
  sl.registerLazySingleton<MessageRepo>(() => MessageRepo(sl()));
  sl.registerLazySingleton<CallRepo>(() => CallRepo(sl()));

  // AI settings (local persistence) — loaded eagerly so AiRepo has a
  // valid in-memory config before the first message is sent.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<AiSettingsStore>(() => AiSettingsStore(prefs));
  await sl<AiSettingsStore>().load();
  sl.registerLazySingleton<AiRepo>(() => AiRepo(sl()));

  // ─── Services ──────────────────────────────────────────────────
  sl.registerLazySingleton<PresenceService>(() => PresenceService(sl()));
  sl.registerLazySingleton<PermissionService>(() => PermissionService());
  sl.registerLazySingleton<WebRtcService>(() => WebRtcService());

  // ─── Cubits ────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<ChatsCubit>(() => ChatsCubit(sl(), sl()));
  sl.registerFactory<MessagesCubit>(() => MessagesCubit(sl(), sl()));
  sl.registerFactory<UsersCubit>(() => UsersCubit(sl(), sl()));
  sl.registerFactory<AiSettingsCubit>(() => AiSettingsCubit(sl(), sl()));
  sl.registerLazySingleton<CallCubit>(() => CallCubit(sl(), sl(), sl()));
}
