import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/friend_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../application/friend_controller.dart';
import 'friend_avatar.dart';
import 'friend_errors.dart';

/// Friends hub: own username (copy/share), accepted friends, and pending
/// requests (incoming/outgoing). See docs/plan-dev/tabungan-bersama-plan.txt
/// BAGIAN 2.
class FriendListPage extends ConsumerWidget {
  const FriendListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final incomingCount = ref.watch(friendListControllerProvider).valueOrNull?.meta.incomingPending ?? 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.frdPageTitle),
          actions: [
            IconButton(
              tooltip: l10n.frdAddTitle,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () => context.push('/friends/add'),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: l10n.frdTabFriends),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.frdTabRequests),
                    if (incomingCount > 0) ...[
                      const SizedBox(width: 6),
                      Badge(label: Text('$incomingCount')),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_FriendsTab(), _RequestsTab()]),
      ),
    );
  }
}

void _showError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  final message = error is ApiException ? friendErrorMessage(l10n, error) : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _FriendsTab extends ConsumerWidget {
  const _FriendsTab();

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref, FriendModel friend) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.frdRemoveTitle),
        content: Text(l10n.frdRemoveMessage(friend.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.frdCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.frdRemoveConfirm, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(friendListControllerProvider.notifier).remove(friend.userId);
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final friendsAsync = ref.watch(friendListControllerProvider);

    Future<void> refresh() async {
      ref.invalidate(myUsernameProvider);
      await ref.read(friendListControllerProvider.notifier).refresh();
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: friendsAsync.when(
        loading: () => skeletonListTiles(hasTrailing: false),
        error: (error, _) => scrollableCenter(
          ListErrorState(message: error.toString(), onRetry: () async => ref.invalidate(friendListControllerProvider)),
        ),
        data: (data) {
          final friends = data.friends;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const _MyUsernameCard(),
              const SizedBox(height: 16),
              if (friends.isEmpty)
                ListEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: l10n.frdEmptyTitle,
                  subtitle: l10n.frdEmptySubtitle,
                )
              else
                for (final friend in friends) ...[
                  _PersonTile(
                    name: friend.name,
                    username: friend.username,
                    avatarUrl: friend.avatarUrl,
                    trailing: IconButton(
                      tooltip: l10n.frdRemoveTitle,
                      icon: Icon(Icons.person_remove_outlined, color: AppColors.textSecondary),
                      onPressed: () => _confirmRemove(context, ref, friend),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final requestsAsync = ref.watch(friendRequestsControllerProvider);
    final controller = ref.read(friendRequestsControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: requestsAsync.when(
        loading: () => skeletonListTiles(hasTrailing: false),
        error: (error, _) => scrollableCenter(
          ListErrorState(
            message: error.toString(),
            onRetry: () async => ref.invalidate(friendRequestsControllerProvider),
          ),
        ),
        data: (state) {
          if (state.incoming.isEmpty && state.outgoing.isEmpty) {
            return scrollableCenter(
              ListEmptyState(
                icon: Icons.mark_email_unread_outlined,
                title: l10n.frdRequestsEmptyTitle,
                subtitle: l10n.frdRequestsEmptySubtitle,
              ),
            );
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (state.incoming.isNotEmpty) ...[
                _SectionTitle(l10n.frdIncomingSection),
                for (final request in state.incoming) ...[
                  _PersonTile(
                    name: request.name,
                    username: request.username,
                    avatarUrl: request.avatarUrl,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.frdDecline,
                          icon: Icon(Icons.close_rounded, color: AppColors.error),
                          onPressed: () => _run(context, () => controller.decline(request.id)),
                        ),
                        IconButton(
                          tooltip: l10n.frdAccept,
                          icon: Icon(Icons.check_rounded, color: AppColors.primary),
                          onPressed: () => _run(context, () => controller.accept(request.id)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
              ],
              if (state.outgoing.isNotEmpty) ...[
                _SectionTitle(l10n.frdOutgoingSection),
                for (final request in state.outgoing) ...[
                  _PersonTile(
                    name: request.name,
                    username: request.username,
                    avatarUrl: request.avatarUrl,
                    trailing: TextButton(
                      onPressed: () => _run(context, () => controller.cancel(request.id)),
                      child: Text(l10n.frdCancelRequest),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.name, required this.username, this.avatarUrl, required this.trailing});

  final String name;
  final String username;
  final String? avatarUrl;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          FriendAvatar(name: name, url: avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text('@$username', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _MyUsernameCard extends ConsumerWidget {
  const _MyUsernameCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usernameAsync = ref.watch(myUsernameProvider);
    final username = usernameAsync.valueOrNull;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.frdMyUsername, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  username != null ? '@$username' : (usernameAsync.hasError ? l10n.frdMyUsernameError : '...'),
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (username != null) ...[
            IconButton(
              tooltip: l10n.frdCopyUsername,
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: username));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.frdUsernameCopied)));
              },
            ),
            IconButton(
              tooltip: l10n.frdShareUsername,
              icon: const Icon(Icons.share_rounded, size: 20),
              onPressed: () => SharePlus.instance.share(ShareParams(text: l10n.frdShareText(username))),
            ),
          ],
        ],
      ),
    );
  }
}
