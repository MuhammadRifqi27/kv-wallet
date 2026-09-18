import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/savings_goal_controller.dart';
import 'savings_goal_style.dart';

class SavingsGoalListPage extends ConsumerWidget {
  const SavingsGoalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsGoalControllerProvider);
    final controller = ref.read(savingsGoalControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.walletSavingsGoalListTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/savings-goals/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: summaryAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : l10n.walletSavingsGoalListLoadError,
              onRetry: controller.refresh,
            ),
          ),
          data: (summary) {
            if (summary.goals.isEmpty) {
              return scrollableCenter(
                ListEmptyState(
                  icon: Icons.savings_outlined,
                  title: l10n.walletSavingsGoalListEmptyTitle,
                  subtitle: l10n.walletSavingsGoalListEmptySubtitle,
                ),
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _SummaryRow(activeCount: summary.activeCount, achievedCount: summary.achievedCount),
                const SizedBox(height: 16),
                for (final goal in summary.goals) ...[
                  _GoalCard(goal: goal),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.activeCount, required this.achievedCount});

  final int activeCount;
  final int achievedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(label: l10n.walletSavingsGoalListActiveLabel, value: '$activeCount', color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _SummaryTile(label: l10n.walletSavingsGoalListAchievedLabel, value: '$achievedCount', color: AppColors.success),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            AppLocalizations.of(context).walletSavingsGoalListSummarySuffix(label),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final SavingsGoalModel goal;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.walletSavingsGoalListDeleteDialogTitle),
        content: Text(l10n.walletSavingsGoalListDeleteDialogContent(goal.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.walletSavingsGoalListCancel)),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.walletSavingsGoalListDeleteConfirm, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(savingsGoalControllerProvider.notifier).removeGoal(goal.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.walletSavingsGoalListArchiveDialogTitle),
        content: Text(l10n.walletSavingsGoalListArchiveDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.walletSavingsGoalListCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.walletSavingsGoalListArchiveConfirm)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(savingsGoalControllerProvider.notifier).archiveGoal(goal.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = savingsGoalColorFor(goal.color);
    final isArchived = goal.status == SavingsGoalStatus.archived;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/savings-goals/${goal.id}', extra: goal),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
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
                    child: Icon(savingsGoalIconFor(goal.icon), color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        if (goal.purpose != null && goal.purpose!.isNotEmpty)
                          Text(
                            goal.purpose!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  if (goal.status != SavingsGoalStatus.active) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (goal.status == SavingsGoalStatus.achieved ? AppColors.success : AppColors.textSecondary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        savingsGoalStatusLabel(context, goal.status),
                        style: TextStyle(
                          color: goal.status == SavingsGoalStatus.achieved ? AppColors.success : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/savings-goals/form', extra: goal);
                      } else if (value == 'archive') {
                        _confirmArchive(context, ref);
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.walletSavingsGoalListEditAction)),
                      if (!isArchived)
                        PopupMenuItem(value: 'archive', child: Text(l10n.walletSavingsGoalListArchiveConfirm)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.walletSavingsGoalListDeleteConfirm)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.walletSavingsGoalListProgressAmounts(formatRupiah(goal.savedAmount), formatRupiah(goal.targetAmount)),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '${goal.progressPercent.toStringAsFixed(0)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
              if (goal.isOverAllocated) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.walletSavingsGoalListOverAllocatedWarning,
                        style: TextStyle(color: AppColors.accent, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
