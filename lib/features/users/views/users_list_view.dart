import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di_container.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_text_field.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';

/// Directory of all registered users — start a new 1:1 chat from here.
class UsersListView extends StatelessWidget {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return BlocProvider(
      create: (_) => sl<UsersCubit>()..watchUsers(authState.user.uid),
      child: _UsersListBody(
        myUid: authState.user.uid,
        myEmail: authState.user.email,
      ),
    );
  }
}

class _UsersListBody extends StatefulWidget {
  const _UsersListBody({required this.myUid, required this.myEmail});

  final String myUid;
  final String myEmail;

  @override
  State<_UsersListBody> createState() => _UsersListBodyState();
}

class _UsersListBodyState extends State<_UsersListBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Users')),
      body: Column(
        children: [
          SearchTextField(
            controller: _searchController,
            hintText: 'Search users by name or email...',
            onChanged:
                (value) => context.read<UsersCubit>().setSearchQuery(value),
          ),
          Expanded(
            child: BlocConsumer<UsersCubit, UsersState>(
              listenWhen:
                  (previous, current) =>
                      current is UsersChatReady || current is UsersError,
              listener: (context, state) {
                if (state is UsersChatReady) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chat,
                    arguments: ChatViewArgs(
                      chatId: state.chatId,
                      receiverId: state.otherUser.uid,
                      receiverName: state.otherUser.displayName,
                    ),
                  );
                } else if (state is UsersError) {
                  AppSnackBar.error(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is UsersLoading || state is UsersInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is UsersError) {
                  return EmptyState(
                    icon: Icons.cloud_off,
                    title: 'تعذر تحميل المستخدمين',
                    subtitle: state.message,
                  );
                }

                // UsersChatReady passes through here briefly; fall back to
                // the embedded previous state.
                final loaded =
                    state is UsersLoaded
                        ? state
                        : (state as UsersChatReady).previous;
                final users = loaded.filtered;

                if (users.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title:
                        loaded.searchQuery.isEmpty
                            ? 'لا يوجد مستخدمون بعد'
                            : 'لا يوجد نتائج مطابقة',
                  );
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: UserAvatar(
                        initial: user.initial,
                        photoUrl: user.photoUrl,
                        online: user.online,
                        showOnlineDot: true,
                      ),
                      title: Text(
                        user.displayName.isEmpty
                            ? user.email
                            : user.displayName,
                      ),
                      subtitle: Text(user.email),
                      trailing:
                          loaded.isCreatingChat
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : null,
                      onTap:
                          loaded.isCreatingChat
                              ? null
                              : () => context.read<UsersCubit>().startChatWith(
                                currentUid: widget.myUid,
                                currentEmail: widget.myEmail,
                                otherUser: user,
                              ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
