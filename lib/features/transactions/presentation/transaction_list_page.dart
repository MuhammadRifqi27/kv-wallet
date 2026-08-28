import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/transaction_list_controller.dart';

class TransactionListPage extends ConsumerWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListControllerProvider);
    final controller = ref.read(transactionListControllerProvider.notifier);
    final typeFilter = ref.watch(transactionTypeFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transaksi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<TransactionType?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Semua')),
                ButtonSegment(value: TransactionType.income, label: Text('Pemasukan')),
                ButtonSegment(value: TransactionType.expense, label: Text('Pengeluaran')),
              ],
              selected: {typeFilter},
              onSelectionChanged: (selection) =>
                  ref.read(transactionTypeFilterProvider.notifier).state = selection.first,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: transactionsAsync.when(
                loading: () => scrollableCenter(const AppLoadingIndicator()),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : 'Gagal memuat transaksi.',
                    onRetry: controller.refresh,
                  ),
                ),
                data: (result) {
                  if (result.transactions.isEmpty) {
                    return scrollableCenter(
                      const ListEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum ada transaksi',
                        subtitle: 'Tekan tombol + untuk mencatat pemasukan atau pengeluaran.',
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: result.transactions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SummaryRow(result: result),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionTile(transaction: result.transactions[index - 1]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.result});

  final TransactionListResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Pemasukan',
            value: formatRupiah(result.totalIncome),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Pengeluaran',
            value: formatRupiah(result.totalExpense),
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Saldo Bersih',
            value: formatRupiah(result.netBalance),
            color: result.netBalance >= 0 ? AppColors.primary : AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi ini akan dihapus permanen.'),
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
      await ref.read(transactionListControllerProvider.notifier).removeTransaction(transaction.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;

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
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
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
                  transaction.categoryName ?? 'Kategori #${transaction.categoryId}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    formatIndonesianDateShort(transaction.date),
                    if (transaction.portfolioName != null && transaction.portfolioName != '-')
                      transaction.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/transactions/form', extra: transaction);
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}
