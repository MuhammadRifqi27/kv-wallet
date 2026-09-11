import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal_model.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Target Tabungan')),
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
              message: error is ApiException ? error.message : 'Gagal memuat target tabungan.',
              onRetry: controller.refresh,
            ),
          ),
          data: (summary) {
            if (summary.goals.isEmpty) {
              return scrollableCenter(
                const ListEmptyState(
                  icon: Icons.savings_outlined,
                  title: 'Belum ada target tabungan',
                  subtitle: 'Tekan tombol + untuk membuat target pertama Anda.',
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
    return Row(
      children: [
        Expanded(child: _SummaryTile(label: 'Aktif', value: '$activeCount', color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryTile(label: 'Tercapai', value: '$achievedCount', color: AppColors.success)),
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
          Text('$label Goal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final SavingsGoalModel goal;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus target?'),
        content: Text('Target "${goal.name}" beserta seluruh riwayat nabung/tariknya akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Arsipkan target?'),
        content: const Text(
          'Target berhenti dihitung aktif/tercapai, tapi riwayatnya tetap tersimpan. Tidak bisa dibatalkan dari aplikasi.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Arsipkan')),
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
                        savingsGoalStatusLabel(goal.status),
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
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!isArchived) const PopupMenuItem(value: 'archive', child: Text('Arsipkan')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus')),
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
                    '${formatRupiah(goal.savedAmount)} dari ${formatRupiah(goal.targetAmount)}',
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
                    const Expanded(
                      child: Text(
                        'Total alokasi ke akun ini melebihi saldo aslinya.',
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
