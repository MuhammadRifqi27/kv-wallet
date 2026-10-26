import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/membership_status_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../auth/application/auth_controller.dart';
import '../../../shared/widgets/list_states.dart';
import '../application/membership_controller.dart';

/// Information-only screen: shows the account's membership status and what
/// each plan includes. There is deliberately NO price, payment instruction,
/// or "choose/upgrade" action anywhere in the app — memberships are handled
/// outside it, and Google Play's Payments policy forbids steering users to
/// an off-Play payment from inside an app distributed there. See
/// docs/plan-dev/playstore-launch-plan.md bagian 2.
///
/// Refreshes membership status/plans and, if that reveals the account is now
/// a paid member, also refetches `/auth/me` so permissions (and locked
/// navbar tabs) update immediately instead of needing a re-login.
Future<void> _refreshMembership(WidgetRef ref) async {
  ref.invalidate(membershipPlansProvider);
  ref.invalidate(membershipStatusProvider);
  final status = await ref.read(membershipStatusProvider.future);
  if (status.isPaidMember) {
    await ref.read(authControllerProvider.notifier).refreshUser();
  }
}

class MembershipPlansPage extends ConsumerWidget {
  const MembershipPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(membershipStatusProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.investMembershipTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _refreshMembership(ref),
        child: statusAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : l10n.investMembershipStatusLoadError,
              onRetry: () async => ref.invalidate(membershipStatusProvider),
            ),
          ),
          data: (status) => _MembershipBody(status: status),
        ),
      ),
    );
  }
}

class _MembershipBody extends ConsumerWidget {
  const _MembershipBody({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final l10n = AppLocalizations.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(status: status),
        const SizedBox(height: 12),
        Text(l10n.investMembershipInfoNote, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        const SizedBox(height: 24),
        Text(
          l10n.investChoosePlanTitle,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        plansAsync.when(
          loading: () => Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (error, _) => ListErrorState(
            message: error is ApiException ? error.message : l10n.investPlanListLoadError,
            onRetry: () async => ref.invalidate(membershipPlansProvider),
          ),
          data: (plans) => plans.isEmpty
              ? ListEmptyState(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.investPlanListEmptyTitle,
                  subtitle: l10n.investPlanListEmptySubtitle,
                )
              : Column(
                  children: [
                    for (final plan in plans) ...[
                      _PlanCard(plan: plan, isCurrent: status.membershipPlan?.id == plan.id),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String title;
    final String subtitle;
    final Color color;
    final IconData icon;

    if (status.isPaidMember) {
      title = status.membershipPlan?.name ?? l10n.investMemberFallbackName;
      final expiresAt = status.membershipExpiresAt;
      subtitle = expiresAt != null
          ? l10n.investActiveUntil(formatLocalizedDate(expiresAt, Localizations.localeOf(context)))
          : l10n.investActiveLabel;
      color = AppColors.success;
      icon = Icons.workspace_premium_rounded;
    } else if (status.isPendingVerification) {
      title = status.membershipPlan?.name ?? l10n.investMemberFallbackName;
      subtitle = l10n.investPendingVerificationSubtitle;
      color = AppColors.accent;
      icon = Icons.hourglass_top_rounded;
    } else {
      title = l10n.investFreeLabel;
      subtitle = l10n.investNoMembershipSubtitle;
      color = AppColors.textSecondary;
      icon = Icons.account_circle_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrent});

  final MembershipPlan plan;
  final bool isCurrent;

  Future<void> _showPlanDetail(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PlanDetailSheet(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showPlanDetail(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border, width: isCurrent ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              if (isCurrent)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    l10n.investActivePlanLabel,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Benefit list for one plan (from [MembershipPlan.benefits]) — no price and
/// no action button.
class _PlanDetailSheet extends StatelessWidget {
  const _PlanDetailSheet({required this.plan});

  final MembershipPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plan.name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (plan.benefits.isNotEmpty) ...[
              Text(
                l10n.investPlanFeaturesTitle,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [for (final benefit in plan.benefits) _BenefitRow(text: benefit)],
                  ),
                ),
              ),
            ] else
              Text(
                l10n.investPlanFeaturesUnavailable,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
