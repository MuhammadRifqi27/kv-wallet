import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/list_states.dart';
import '../../auth/application/auth_controller.dart';
import '../../friends/presentation/friend_avatar.dart';
import '../../friends/presentation/friend_picker_sheet.dart';
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/savings_goal_controller.dart';
import 'savings_goal_errors.dart';
import 'savings_goal_style.dart';

/// Server cap per goal, owner included (docs rule 3).
const _maxPeoplePerGoal = 5;

/// Opened by tapping a goal card on [SavingsGoalListPage]. `goal` is the
/// snapshot at tap time; the header re-reads the live value from
/// [savingsGoalControllerProvider] (falling back to that snapshot) so
/// `saved_amount`/`progress_percent`/`status` reflect any contribution
/// logged from this same page without needing to pop back first — same
/// "valueOrNull...firstOrNull ?? fallback" pattern as AssetDetailPage.
class SavingsGoalDetailPage extends ConsumerWidget {
  const SavingsGoalDetailPage({super.key, required this.goal});

  final SavingsGoalModel goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(savingsGoalControllerProvider).valueOrNull?.goals.where((g) => g.id == goal.id).firstOrNull ??
        goal;
    final color = savingsGoalColorFor(latest.color);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(latest.name),
        actions: [
          if (latest.isShared && latest.isOwner && latest.status != SavingsGoalStatus.archived)
            IconButton(
              tooltip: l10n.sgsInviteAction,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: () => _inviteFriends(context, ref, latest),
            ),
          if (latest.isShared && !latest.isOwner)
            IconButton(
              tooltip: l10n.sgsLeaveConfirm,
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _leave(context, ref, latest),
            ),
        ],
      ),
      floatingActionButton: latest.status == SavingsGoalStatus.archived
          ? null
          : FloatingActionButton(
              onPressed: () => _openContributionForm(context, ref, latest),
              backgroundColor: AppColors.primary,
              tooltip: l10n.walletSavingsGoalDetailAddEntryTooltip,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(savingsGoalContributionsProvider(goal.id));
          await ref.read(savingsGoalControllerProvider.notifier).refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _GoalSummaryCard(goal: latest, color: color),
            if (latest.isShared) ...[
              const SizedBox(height: 16),
              _MembersCard(goal: latest),
            ],
            const SizedBox(height: 24),
            _HistorySection(goal: latest),
          ],
        ),
      ),
    );
  }

  void _openContributionForm(BuildContext context, WidgetRef ref, SavingsGoalModel latest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _ContributionFormSheet(goal: latest),
    );
  }

  /// Owner only. Seats already taken (active + still-pending invites) count
  /// toward the 5-person cap, so the picker only offers what still fits.
  Future<void> _inviteFriends(BuildContext context, WidgetRef ref, SavingsGoalModel latest) async {
    final l10n = AppLocalizations.of(context);
    final occupied = latest.members.where((m) => m.status != SavingsGoalMemberStatus.left).toList();
    final seatsLeft = _maxPeoplePerGoal - occupied.length;
    if (seatsLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sgsErrMemberLimit)));
      return;
    }
    final picked = await showFriendPickerSheet(
      context,
      maxSelect: seatsLeft,
      excludeUserIds: occupied.map((m) => m.userId).toList(),
    );
    if (picked == null || picked.isEmpty || !context.mounted) return;
    try {
      await ref.read(savingsGoalControllerProvider.notifier).inviteMembers(goalId: latest.id, userIds: picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sgsInviteSent(picked.length))));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sharedGoalErrorMessage(l10n, e))));
      }
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, SavingsGoalModel latest) async {
    final l10n = AppLocalizations.of(context);
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.sgsLeaveTitle),
        content: Text(l10n.sgsLeaveMessage(latest.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.walletSavingsGoalDetailCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.sgsLeaveConfirm, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(savingsGoalControllerProvider.notifier).removeMember(goalId: latest.id, userId: userId);
      if (context.mounted) context.pop();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sharedGoalErrorMessage(l10n, e))));
      }
    }
  }
}

/// People on a shared goal with each one's total contribution. The owner
/// can remove anyone else (or cancel an unanswered invite).
class _MembersCard extends ConsumerWidget {
  const _MembersCard({required this.goal});

  final SavingsGoalModel goal;

  Future<void> _remove(BuildContext context, WidgetRef ref, SavingsGoalMember member) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.sgsRemoveMemberTitle),
        content: Text(l10n.sgsRemoveMemberMessage(member.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.walletSavingsGoalDetailCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.sgsRemoveMemberConfirm, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(savingsGoalControllerProvider.notifier).removeMember(goalId: goal.id, userId: member.userId);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sharedGoalErrorMessage(l10n, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = savingsGoalColorFor(goal.color);
    final isArchived = goal.status == SavingsGoalStatus.archived;

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
          Text(
            l10n.sgsMembersTitle,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.sgsMyContribution(formatRupiah(goal.myContribution)),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          for (final member in goal.members) ...[
            Row(
              children: [
                FriendAvatar(name: member.name, url: member.avatarUrl, radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                            ),
                          ),
                          if (member.isOwner || member.status != SavingsGoalMemberStatus.active) ...[
                            const SizedBox(width: 6),
                            Text(
                              member.isOwner
                                  ? l10n.sgsRoleOwner
                                  : (member.status == SavingsGoalMemberStatus.pending
                                      ? l10n.sgsMemberPending
                                      : l10n.sgsMemberLeft),
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (member.contributionPercent / 100).clamp(0, 1),
                          minHeight: 5,
                          backgroundColor: AppColors.background,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(member.contributedAmount),
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                    ),
                    Text(
                      '${member.contributionPercent.toStringAsFixed(0)}%',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                  ],
                ),
                if (goal.isOwner && !member.isOwner && !isArchived && member.status != SavingsGoalMemberStatus.left)
                  IconButton(
                    tooltip: l10n.sgsRemoveMemberTitle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                    onPressed: () => _remove(context, ref, member),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Contribution/withdrawal ledger. On a shared goal it lists everyone's
/// rows (with who logged each) and offers a "only mine" filter, applied
/// client-side from `is_mine`.
class _HistorySection extends ConsumerStatefulWidget {
  const _HistorySection({required this.goal});

  final SavingsGoalModel goal;

  @override
  ConsumerState<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends ConsumerState<_HistorySection> {
  bool _mineOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goal = widget.goal;
    final contributionsAsync = ref.watch(savingsGoalContributionsProvider(goal.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.walletSavingsGoalDetailHistoryTitle,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
            ),
            if (goal.isShared)
              FilterChip(
                label: Text(l10n.sgsOnlyMine),
                selected: _mineOnly,
                showCheckmark: false,
                onSelected: (value) => setState(() => _mineOnly = value),
              ),
          ],
        ),
        const SizedBox(height: 10),
        contributionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: AppLoadingIndicator()),
          ),
          error: (error, _) => ListErrorState(
            message: error is ApiException ? error.message : l10n.walletSavingsGoalDetailLoadHistoryError,
            onRetry: () async => ref.invalidate(savingsGoalContributionsProvider(goal.id)),
          ),
          data: (all) {
            final contributions = _mineOnly ? all.where((c) => c.isMine).toList() : all;
            if (contributions.isEmpty) {
              return ListEmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.walletSavingsGoalDetailEmptyTitle,
                subtitle: l10n.walletSavingsGoalDetailEmptySubtitle,
              );
            }
            // ListView.builder (shrinkWrap, non-scrolling - it's nested
            // inside the page's outer ListView): contribution/withdrawal
            // history is a user-grown collection that can get long over
            // time. See docs/ide-improvement-fitur-existing.txt BAGIAN F #38.
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contributions.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ContributionTile(
                  goalId: goal.id,
                  contribution: contributions[index],
                  showContributor: goal.isShared,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({required this.goal, required this.color});

  final SavingsGoalModel goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(savingsGoalIconFor(goal.icon), color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    if (goal.purpose != null && goal.purpose!.isNotEmpty)
                      Text(
                        goal.purpose!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  savingsGoalStatusLabel(context, goal.status),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(l10n.walletSavingsGoalDetailCollectedLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            formatRupiah(goal.savedAmount),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.walletSavingsGoalDetailTargetAmount(formatRupiah(goal.targetAmount)),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              Text(
                '${goal.progressPercent.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          if (goal.remainingAmount > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.walletSavingsGoalDetailRemainingAmount(formatRupiah(goal.remainingAmount)),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.targetDate != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.walletSavingsGoalDetailDeadline(formatLocalizedDate(goal.targetDate!, Localizations.localeOf(context))),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.portfolioName != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.walletSavingsGoalDetailDefaultAccount(goal.portfolioName!),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          if (goal.isOverAllocated) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.walletSavingsGoalDetailOverAllocatedWarning,
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContributionTile extends ConsumerWidget {
  const _ContributionTile({required this.goalId, required this.contribution, this.showContributor = false});

  final int goalId;
  final SavingsGoalContributionModel contribution;

  /// Shared goals: prefix the subtitle with who logged the row.
  final bool showContributor;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.walletSavingsGoalDetailDeleteEntryTitle),
        content: Text(l10n.walletSavingsGoalDetailDeleteEntryContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.walletSavingsGoalDetailCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.walletSavingsGoalDetailDeleteConfirm, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(savingsGoalControllerProvider.notifier)
          .removeContribution(goalId: goalId, contributionId: contribution.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWithdrawal = contribution.type == SavingsGoalEntryType.withdrawal;
    final color = isWithdrawal ? AppColors.error : AppColors.success;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              isWithdrawal ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWithdrawal ? l10n.walletSavingsGoalDetailWithdrawLabel : l10n.walletSavingsGoalDetailContributeLabel,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (showContributor) contribution.isMine ? l10n.sgsYou : (contribution.contributorName ?? '-'),
                    formatLocalizedDateShort(contribution.date, Localizations.localeOf(context)),
                    if (contribution.portfolioName != null) contribution.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (contribution.note != null && contribution.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contribution.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isWithdrawal ? '-' : '+'} ${formatRupiah(contribution.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          // Only the person who logged a row may delete it (docs).
          if (contribution.isMine)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 18),
              onPressed: () => _confirmDelete(context, ref),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ContributionFormSheet extends ConsumerStatefulWidget {
  const _ContributionFormSheet({required this.goal});

  final SavingsGoalModel goal;

  @override
  ConsumerState<_ContributionFormSheet> createState() => _ContributionFormSheetState();
}

class _ContributionFormSheetState extends ConsumerState<_ContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  SavingsGoalEntryType _type = SavingsGoalEntryType.contribution;
  DateTime _date = DateTime.now();
  late int? _selectedPortfolioId = widget.goal.portfolioId;

  bool _isSubmitting = false;
  ApiException? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // A contribution/withdrawal records money that has already moved —
    // capped at today instead of a year out. See
    // docs/ide-improvement-fitur-existing.txt BAGIAN D #19.
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickPortfolio(List<PortfolioModel> portfolios) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _ContributionPortfolioPickerSheet(portfolios: portfolios, selectedId: _selectedPortfolioId),
    );
    if (selected == null) return;
    setState(() => _selectedPortfolioId = selected == 0 ? null : selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final amount = parseRupiahInput(_amountController.text)!;
    final note = _noteController.text.trim();

    try {
      await ref.read(savingsGoalControllerProvider.notifier).addContribution(
            goalId: widget.goal.id,
            type: _type,
            date: _date,
            amount: amount,
            financePortfolioId: _selectedPortfolioId,
            note: note.isEmpty ? null : note,
          );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfoliosAsync = ref.watch(portfolioListControllerProvider);
    final generalError = _error != null && _error!.fieldErrors == null;
    final selectedPortfolioName =
        portfoliosAsync.valueOrNull?.where((p) => p.id == _selectedPortfolioId).firstOrNull?.accountName;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  l10n.walletSavingsGoalDetailAddEntryTooltip,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                if (generalError) ...[
                  ErrorBanner(message: _error!.message),
                  const SizedBox(height: 16),
                ],
                SegmentedButton<SavingsGoalEntryType>(
                  segments: [
                    ButtonSegment(
                      value: SavingsGoalEntryType.contribution,
                      label: Text(l10n.walletSavingsGoalDetailContributeLabel),
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: SavingsGoalEntryType.withdrawal,
                      label: Text(l10n.walletSavingsGoalDetailWithdrawLabel),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() => _type = selection.first),
                ),
                if (widget.goal.isShared && _type == SavingsGoalEntryType.withdrawal) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.sgsWithdrawHint(formatRupiah(widget.goal.myContribution)),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 16),
                Text(l10n.walletSavingsGoalDetailDateLabel, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          formatLocalizedDate(_date, Localizations.localeOf(context)),
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.walletSavingsGoalDetailAmountLabel,
                  controller: _amountController,
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textInputAction: TextInputAction.next,
                  errorText: _error?.errorFor('amount'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.walletSavingsGoalDetailAmountRequired;
                    final parsed = parseRupiahInput(value);
                    if (parsed == null || parsed <= 0) return l10n.walletSavingsGoalDetailAmountInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(l10n.walletSavingsGoalDetailAccountLabel, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                portfoliosAsync.when(
                  loading: () => LinearProgressIndicator(color: AppColors.primary),
                  error: (error, _) => Text(
                    l10n.walletSavingsGoalDetailLoadAccountsError,
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  data: (portfolios) => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: portfolios.isEmpty ? null : () => _pickPortfolio(portfolios),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedPortfolioName ??
                                  (portfolios.isEmpty
                                      ? l10n.walletSavingsGoalDetailNoAccounts
                                      : l10n.walletSavingsGoalDetailNoAccountRecorded),
                              style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.walletSavingsGoalDetailNoteLabel,
                  controller: _noteController,
                  icon: Icons.notes_rounded,
                  textInputAction: TextInputAction.done,
                  errorText: _error?.errorFor('note'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: l10n.walletSavingsGoalDetailSaveAction, isLoading: _isSubmitting, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContributionPortfolioPickerSheet extends StatelessWidget {
  const _ContributionPortfolioPickerSheet({required this.portfolios, required this.selectedId});

  final List<PortfolioModel> portfolios;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
              AppLocalizations.of(context).walletSavingsGoalDetailPickAccountSheetTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedId == null ? AppColors.primaryLight : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedId == null ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(
                          AppLocalizations.of(context).walletSavingsGoalDetailNoAccountRecorded,
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  for (final portfolio in portfolios)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(portfolio.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: portfolio.id == selectedId ? AppColors.primaryLight : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: portfolio.id == selectedId ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  portfolio.accountName,
                                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                ),
                              ),
                              if (portfolio.id == selectedId)
                                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
