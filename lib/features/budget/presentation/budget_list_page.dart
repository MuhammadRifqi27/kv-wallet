import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/cycle_period_filter_bar.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/budget_controller.dart';

class BudgetListPage extends ConsumerWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetControllerProvider);
    final controller = ref.read(budgetControllerProvider.notifier);
    final period = ref.watch(selectedBudgetPeriodProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budget/form'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CyclePeriodFilterBar(
              period: period,
              onChanged: (value) => ref.read(selectedBudgetPeriodProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: budgetAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : 'Gagal memuat budget.',
                    onRetry: controller.refresh,
                  ),
                ),
                data: (summary) => _BudgetBody(summary: summary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetBody extends StatelessWidget {
  const _BudgetBody({required this.summary});

  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    if (summary.categories.isEmpty) {
      return scrollableCenter(
        const Text(
          'Belum ada budget untuk bulan ini.\nTap tombol + untuk menambah.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 16),
        const Text(
          'Per Kategori',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap salah satu untuk mengubah jumlah budget-nya.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 10),
        for (final category in summary.categories) ...[
          _BudgetCategoryCard(item: category),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final BudgetSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final overBudget = summary.totalSpent > summary.totalBudget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Budget', style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            formatRupiah(summary.totalBudget),
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.totalBudget <= 0 ? 0 : (summary.totalSpent / summary.totalBudget).clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.15),
              color: overBudget ? AppColors.error : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terpakai ${formatRupiah(summary.totalSpent)}',
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({required this.item});

  final BudgetCategoryItem item;

  @override
  Widget build(BuildContext context) {
    final overBudget = item.isOverBudget;
    final barColor = overBudget ? AppColors.error : AppColors.primary;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/budget/form', extra: item),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    formatRupiah(item.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  color: barColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                overBudget
                    ? 'Terpakai ${formatRupiah(item.spent)} — melebihi budget'
                    : 'Terpakai ${formatRupiah(item.spent)} dari ${formatRupiah(item.amount)}',
                style: TextStyle(color: overBudget ? AppColors.error : AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
