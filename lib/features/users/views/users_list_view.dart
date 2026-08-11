import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di_container.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_text_field.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/data/user_model.dart';
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
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(
        title: const Text('Contacts'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SearchTextField(
            controller: _searchController,
            hintText: 'Search contacts...',
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

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _UserCard(
                      user: user,
                      isBusy: loaded.isCreatingChat,
                      onTap: loaded.isCreatingChat
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

/// Rounded card for one contact in the directory.
class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isBusy,
    required this.onTap,
  });

  final UserModel user;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName =
        user.displayName.isEmpty ? user.email : user.displayName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        shadowColor: AppColors.primaryLight.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(
                  initial: user.initial,
                  photoUrl: user.photoUrl,
                  online: user.online,
                  showOnlineDot: true,
                  radius: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _OnlineChip(online: user.online),
                    ],
                  ),
                ),
                if (isBusy)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryMedium,
                        size: 20,
                      ),
                      onPressed: onTap,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill showing Online / Offline.
class _OnlineChip extends StatelessWidget {
  const _OnlineChip({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final color = online ? const Color(0xFF2E7D32) : const Color(0xFF757575);
    final bg = online
        ? const Color(0xFF2E7D32).withValues(alpha: 0.10)
        : const Color(0xFF757575).withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            online ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
