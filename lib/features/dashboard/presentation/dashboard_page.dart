import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/named_amount.dart';
import '../../auth/application/auth_controller.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/dashboard_controller.dart';

/// Whether nominal amounts on the dashboard are hidden behind a mask.
/// Page-local UI state, not part of [dashboardControllerProvider]'s data.
final hideNominalProvider = StateProvider<bool>((ref) => false);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final hideNominal = ref.watch(hideNominalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/branding/logo_mark.png', height: 22, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text('Wallet'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refresh,
        child: dashboardAsync.when(
          loading: () => scrollableCenter(const CircularProgressIndicator(color: AppColors.primary)),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat dashboard.',
              onRetry: controller.refresh,
            ),
          ),
          data: (dashboard) => _DashboardBody(dashboard: dashboard, hideNominal: hideNominal),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.dashboard, required this.hideNominal});

  final DashboardModel dashboard;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final cycleStart = dashboard.cycleStartDate;
    final cycleEnd = dashboard.cycleEndDate;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _NetWorthCard(amount: dashboard.totalNetWorth, cycleStart: cycleStart, cycleEnd: cycleEnd),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.payments_outlined,
                label: 'Saldo Kas',
                value: maskRupiah(dashboard.totalLiquidCash, hide: hideNominal),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                label: 'Saldo Investasi',
                value: maskRupiah(dashboard.totalInvestmentValue, hide: hideNominal),
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.arrow_downward_rounded,
                label: 'Pemasukan',
                value: maskRupiah(dashboard.incomePool, hide: hideNominal),
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.arrow_upward_rounded,
                label: 'Pengeluaran',
                value: maskRupiah(dashboard.monthlyExpense, hide: hideNominal),
                color: AppColors.error,
              ),
            ),
          ],
        ),
        if (dashboard.portfolios.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Semua Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          for (final portfolio in dashboard.portfolios) ...[
            _AccountTile(portfolio: portfolio, hideNominal: hideNominal),
            const SizedBox(height: 8),
          ],
        ],
        if (dashboard.incomeBreakdown.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Sumber Pemasukan',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _NamedAmountCard(items: dashboard.incomeBreakdown, hideNominal: hideNominal),
        ],
        if (dashboard.topExpenses.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Kategori Terbesar',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _NamedAmountCard(items: dashboard.topExpenses, hideNominal: hideNominal),
        ],
        if (dashboard.recentTransactions.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Transaksi Terbaru',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          for (final transaction in dashboard.recentTransactions) ...[
            _RecentTransactionTile(transaction: transaction, hideNominal: hideNominal),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _NetWorthCard extends ConsumerWidget {
  const _NetWorthCard({required this.amount, this.cycleStart, this.cycleEnd});

  final double amount;
  final DateTime? cycleStart;
  final DateTime? cycleEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideNominal = ref.watch(hideNominalProvider);
    final userName = ref.watch(authControllerProvider).user?.name;

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
          Text(
            'Halo, ${userName ?? ''}',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (cycleStart != null && cycleEnd != null) ...[
            const SizedBox(height: 4),
            Text(
              'Siklus ${formatIndonesianDate(cycleStart!)} — ${formatIndonesianDate(cycleEnd!)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Total Kekayaan Bersih', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                maskRupiah(amount, hide: hideNominal),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => ref.read(hideNominalProvider.notifier).state = !hideNominal,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    hideNominal ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.portfolio, required this.hideNominal});

  final DashboardPortfolioItem portfolio;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(
              portfolio.isInvestment ? Icons.trending_up_rounded : Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                ),
                if (portfolio.investmentCode != null)
                  Text(
                    portfolio.investmentCode!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
              ],
            ),
          ),
          Text(
            maskRupiah(portfolio.balance, hide: hideNominal),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Shared bar-list layout for "Sumber Pemasukan" (incomeBreakdown) and
/// "Kategori Terbesar" (topExpenses) — both are just a list of {name, amount}.
class _NamedAmountCard extends StatelessWidget {
  const _NamedAmountCard({required this.items, required this.hideNominal});

  final List<NamedAmount> items;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final maxAmount = items.map((c) => c.amount).fold<double>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _AmountBar(item: items[i], maxAmount: maxAmount, hideNominal: hideNominal),
          ],
        ],
      ),
    );
  }
}

class _AmountBar extends StatelessWidget {
  const _AmountBar({required this.item, required this.maxAmount, required this.hideNominal});

  final NamedAmount item;
  final double maxAmount;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0 ? (item.amount / maxAmount).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              maskRupiah(item.amount, hide: hideNominal),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.background,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({required this.transaction, required this.hideNominal});

  final RecentTransactionItem transaction;
  final bool hideNominal;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              transaction.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                ),
                Text(
                  [
                    formatIndonesianDateShort(transaction.date),
                    if (transaction.portfolioName != null) transaction.portfolioName!,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Text(
            hideNominal
                ? maskRupiah(transaction.amount, hide: true)
                : '${transaction.isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
