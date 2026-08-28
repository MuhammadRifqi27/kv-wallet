import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transfer_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../../portfolio/application/portfolio_list_controller.dart';
import '../application/transfer_list_controller.dart';

class TransferListPage extends ConsumerWidget {
  const TransferListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(transferListControllerProvider);
    final controller = ref.read(transferListControllerProvider.notifier);
    // Best-effort fallback for the account name if the transfer response
    // doesn't include one — see TransferModel's schema-verification note.
    final portfoliosById = {
      for (final portfolio in ref.watch(portfolioListControllerProvider).valueOrNull ?? const [])
        portfolio.id: portfolio,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Transfer Antar Akun')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/portfolio/transfers/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: transfersAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat transfer.',
              onRetry: controller.refresh,
            ),
          ),
          data: (transfers) {
            if (transfers.isEmpty) {
              return scrollableCenter(
                const ListEmptyState(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Belum ada transfer',
                  subtitle: 'Tekan tombol + untuk memindahkan dana antar akun Anda.',
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: transfers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return _TransferTile(
                  transfer: transfer,
                  fromAccountName:
                      transfer.portfolioName ?? portfoliosById[transfer.financeInvestmentId]?.accountName,
                  toAccountName:
                      transfer.destinationPortfolioName ?? portfoliosById[transfer.toFinanceInvestmentId]?.accountName,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TransferTile extends ConsumerWidget {
  const _TransferTile({required this.transfer, required this.fromAccountName, required this.toAccountName});

  final TransferModel transfer;
  final String? fromAccountName;
  final String? toAccountName;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus transfer?'),
        content: const Text('Transfer ini akan dihapus permanen, saldo kedua akun akan disesuaikan kembali.'),
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
      await ref.read(transferListControllerProvider.notifier).removeTransfer(transfer.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fromAccountName ?? 'Akun #${transfer.financeInvestmentId}'} → ${toAccountName ?? 'Akun #${transfer.toFinanceInvestmentId}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  formatIndonesianDateShort(transfer.date),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (transfer.description != null && transfer.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transfer.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formatRupiah(transfer.amount),
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/portfolio/transfers/form', extra: transfer);
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
