import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/investment_model.dart';
import '../../../data/models/portfolio_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../auth/application/auth_controller.dart';
import '../../master_data/application/investment_list_controller.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListEmptyState, ListErrorState;
import '../application/portfolio_list_controller.dart';

/// "Transfer Antar Akun" is a premium-only feature (see
/// docs/flutter-navbar-permission-gating-plan.txt — granted by the
/// `internal-transfers` permission, not on the default Member plan). Mirrors
/// the "locked tab" UX in routing/main_shell.dart: always tappable, but a
/// user without the permission gets bounced to the upgrade screen instead
/// of the feature.
void _openTransfers(BuildContext context, WidgetRef ref) {
  final user = ref.read(authControllerProvider).user;
  if (user?.hasPermission('internal-transfers') ?? false) {
    context.push('/portfolio/transfers');
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Fitur ini butuh upgrade membership')),
  );
  context.push('/profile/membership');
}

class PortfolioListPage extends ConsumerWidget {
  const PortfolioListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfoliosAsync = ref.watch(portfolioListControllerProvider);
    final controller = ref.read(portfolioListControllerProvider.notifier);
    // Best-effort — if investments haven't loaded yet, tiles just fall back
    // to showing the raw provider id instead of its name.
    final investmentsById = {
      for (final investment in ref.watch(investmentListControllerProvider).valueOrNull ?? <InvestmentModel>[])
        investment.id: investment,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/portfolio/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _TransferMenuTile(onTap: () => _openTransfers(context, ref)),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refresh,
              child: portfoliosAsync.when(
                loading: () => scrollableCenter(
                  const AppLoadingIndicator(),
                ),
                error: (error, _) => scrollableCenter(
                  ListErrorState(
                    message: error is ApiException ? error.message : 'Gagal memuat portfolio.',
                    onRetry: controller.refresh,
                  ),
                ),
                data: (portfolios) {
                  if (portfolios.isEmpty) {
                    return scrollableCenter(
                      const ListEmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Belum ada akun',
                        subtitle: 'Tekan tombol + untuk menambah akun/dompet pertama Anda.',
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: portfolios.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final portfolio = portfolios[index];
                      return _PortfolioTile(
                        portfolio: portfolio,
                        providerName: investmentsById[portfolio.financeInvestmentId]?.name,
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

/// Replaces the old AppBar icon-only entry point for "Transfer Antar Akun"
/// — a bare icon button was too easy to miss, this reads as an actual menu
/// item. Permission gating (premium-only feature) happens in [_openTransfers].
class _TransferMenuTile extends StatelessWidget {
  const _TransferMenuTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transfer Antar Akun',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pindahkan dana antar akun/dompet Anda',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioTile extends ConsumerWidget {
  const _PortfolioTile({required this.portfolio, required this.providerName});

  final PortfolioModel portfolio;
  final String? providerName;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus akun?'),
        content: Text('Akun "${portfolio.accountName}" akan dihapus permanen.'),
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
      await ref.read(portfolioListControllerProvider.notifier).removePortfolio(portfolio.id);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = portfolio.balance;

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
            child: Icon(
              portfolio.isInvestmentAccount ? Icons.trending_up_rounded : Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.accountName,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  providerName ?? 'Provider #${portfolio.financeInvestmentId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                if (balance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(balance),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: balance < 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/portfolio/form', extra: portfolio);
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
