import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/recurring_transaction_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/recurring_list_controller.dart';

/// Templates that auto-generate real transactions on a schedule — see
/// docs/money-management-alur-bisnis-database.txt "TRANSAKSI BERULANG".
/// No edit here (the API only has create/delete, no update) — delete and
/// re-add instead, same as the backend itself supports.
class RecurringListPage extends ConsumerWidget {
  const RecurringListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringListControllerProvider);
    final controller = ref.read(recurringListControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transaksi Berulang')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/recurring/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: recurringAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat transaksi berulang.',
              onRetry: controller.refresh,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return scrollableCenter(
                const ListEmptyState(
                  icon: Icons.autorenew_rounded,
                  title: 'Belum ada transaksi berulang',
                  subtitle: 'Tekan tombol + untuk membuat template, misal tagihan bulanan.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _RecurringTile(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({required this.item});

  final RecurringTransactionModel item;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus transaksi berulang?'),
        content: Text('Template "${item.name}" akan dihapus permanen. Transaksi yang sudah pernah dibuat tidak terhapus.'),
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
      await ref.read(recurringListControllerProvider.notifier).removeRecurring(item.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = item.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/transactions/recurring/form', extra: item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.autorenew_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        item.frequency.label,
                        item.categoryName ?? 'Kategori #${item.categoryId}',
                        if (item.nextDate != null) 'Berikutnya ${formatIndonesianDateShort(item.nextDate!)}',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
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
                '${isIncome ? '+' : '-'} ${formatRupiah(item.amount)}',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
