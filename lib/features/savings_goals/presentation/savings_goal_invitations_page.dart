import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../application/savings_goal_controller.dart';
import 'savings_goal_errors.dart';
import 'savings_goal_style.dart';

/// Inbox of shared-goal invitations (docs "Tabungan Bersama"). There is no
/// push in v1 — pull to refresh. Accepting makes the goal appear in the
/// goal list; declining just drops the invite.
class SavingsGoalInvitationsPage extends ConsumerWidget {
  const SavingsGoalInvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final invitationsAsync = ref.watch(savingsGoalInvitationsProvider);

    Future<void> refresh() async {
      ref.invalidate(savingsGoalInvitationsProvider);
      await ref.read(savingsGoalInvitationsProvider.future).catchError((_) => <SavingsGoalInvitationModel>[]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.sgsInvitationsTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: refresh,
        child: invitationsAsync.when(
          loading: () => skeletonListTiles(hasTrailing: false, count: 3),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : error.toString(),
              onRetry: () async => ref.invalidate(savingsGoalInvitationsProvider),
            ),
          ),
          data: (invitations) {
            if (invitations.isEmpty) {
              return scrollableCenter(
                ListEmptyState(
                  icon: Icons.mail_outline_rounded,
                  title: l10n.sgsInvitationsEmptyTitle,
                  subtitle: l10n.sgsInvitationsEmptySubtitle,
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: invitations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _InvitationCard(invitation: invitations[index]),
            );
          },
        ),
      ),
    );
  }
}

class _InvitationCard extends ConsumerStatefulWidget {
  const _InvitationCard({required this.invitation});

  final SavingsGoalInvitationModel invitation;

  @override
  ConsumerState<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends ConsumerState<_InvitationCard> {
  bool _isBusy = false;

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isBusy = true);
    try {
      await action();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sharedGoalErrorMessage(l10n, e))));
      // An expired invite can never be answered — drop it from the inbox.
      if (e.code == 'INVITATION_EXPIRED') ref.invalidate(savingsGoalInvitationsProvider);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final invitation = widget.invitation;
    final color = savingsGoalColorFor(invitation.color);
    final controller = ref.read(savingsGoalControllerProvider.notifier);
    final expiresAt = invitation.expiresAt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(savingsGoalIconFor(invitation.icon), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.goalName,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.sgsInvitationFrom(invitation.invitedByName),
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.sgsInvitationTarget(formatRupiah(invitation.targetAmount)),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
          if (expiresAt != null)
            Text(
              l10n.sgsInvitationExpires(formatLocalizedDate(expiresAt, Localizations.localeOf(context))),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isBusy
                      ? null
                      : () => _run(() => controller.declineInvitation(invitation.id), l10n.sgsInvitationDeclined),
                  child: Text(l10n.frdDecline),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isBusy
                      ? null
                      : () => _run(
                            () => controller.acceptInvitation(invitation.id),
                            l10n.sgsInvitationAccepted(invitation.goalName),
                          ),
                  child: _isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : Text(l10n.frdAccept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
