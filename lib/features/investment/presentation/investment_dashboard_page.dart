import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/btc_tracking_model.dart';
import '../../../data/models/crypto_price_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../master_data/presentation/category_list_page.dart' show scrollableCenter, ListErrorState;
import '../application/btc_tracking_controller.dart';
import '../application/crypto_price_controller.dart';

/// Landing page for the "Investment" bottom-nav tab. Currently just Crypto
/// Tracking (the BTC Tracking API) — Stock Tracking/IPO aren't built yet;
/// when they are, this is where a picker/tabs between asset classes would
/// go instead of jumping straight to crypto content.
///
/// Asset-first layout: each row is one asset (BTC, ETH, ...) with its
/// total held value + live price/24h change (from CoinGecko — TradingView
/// has no public data API for third parties, only an embeddable chart
/// widget, which lives on the per-asset detail page instead). Tapping an
/// asset is where you see *which accounts* hold it and how much — the
/// per-account split isn't shown here on the summary.
///
/// Deposit/withdrawal happen via Transfer Antar Akun (real money movement,
/// tagged with an Aset field — see TransferFormPage) — the "+" button here
/// only logs Profit/Loss adjustments (see BtcEntryFormPage), which don't
/// correspond to an actual transfer.
class InvestmentDashboardPage extends ConsumerWidget {
  const InvestmentDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(btcOverviewControllerProvider);
    final controller = ref.read(btcOverviewControllerProvider.notifier);
    // Kept alive inside MainShell's IndexedStack — see AppColors' class doc
    // + MainShell's note on why this needs an explicit watch.
    ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Investment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Aktivitas',
            onPressed: () => context.push('/investment/activity'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/investment/entry-form'),
        backgroundColor: AppColors.primary,
        tooltip: 'Catat Profit/Loss',
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await controller.refresh();
          ref.invalidate(assetPricesProvider);
        },
        child: overviewAsync.when(
          loading: () => scrollableCenter(const AppLoadingIndicator()),
          error: (error, _) => scrollableCenter(
            ListErrorState(
              message: error is ApiException ? error.message : 'Gagal memuat data investasi.',
              onRetry: controller.refresh,
            ),
          ),
          data: (overview) => _InvestmentBody(overview: overview),
        ),
      ),
    );
  }
}

class _InvestmentBody extends ConsumerWidget {
  const _InvestmentBody({required this.overview});

  final BtcOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricesAsync = ref.watch(assetPricesProvider);
    final prices = pricesAsync.valueOrNull ?? const <String, CryptoPrice>{};

    final sortedBalances = [...overview.assetBalances]..sort((a, b) => b.balance.compareTo(a.balance));

    // Sum of each asset's own 24h floating P&L — null (not 0) if not a
    // single asset has a resolved price yet, so the card can tell "no data"
    // apart from "genuinely flat".
    double? totalPnl24h;
    for (final balance in overview.assetBalances) {
      final pnl = prices[balance.asset.toUpperCase()]?.floatingPnl24h(balance.balance);
      if (pnl != null) totalPnl24h = (totalPnl24h ?? 0) + pnl;
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        _TotalValueCard(
          amount: overview.totalValue,
          assetCount: overview.assetBalances.length,
          pnl24h: totalPnl24h,
        ),
        if (sortedBalances.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Aset Anda',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          for (final balance in sortedBalances) ...[
            _AssetRow(balance: balance, price: prices[balance.asset.toUpperCase()]),
            const SizedBox(height: 8),
          ],
        ] else ...[
          const SizedBox(height: 24),
          const _EmptyCryptoAccounts(),
        ],
      ],
    );
  }
}

class _TotalValueCard extends StatelessWidget {
  const _TotalValueCard({required this.amount, required this.assetCount, required this.pnl24h});

  final double amount;
  final int assetCount;

  /// Floating P&L over the last 24h, summed across every asset with a
  /// resolved price — see [CryptoPrice.floatingPnl24h] for what this can
  /// and can't tell you (price movement only, not vs. your original cost).
  final double? pnl24h;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_bitcoin_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Nilai Crypto',
                style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            formatRupiah(amount),
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                assetCount == 0 ? 'Belum ada aset' : '$assetCount aset dilacak',
                style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 12),
              ),
              if (pnl24h != null) ...[
                const SizedBox(width: 8),
                Text('·', style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.4), fontSize: 12)),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final isUp = pnl24h! >= 0;
                    final color = isUp ? AppColors.success : AppColors.error;
                    return Text(
                      'PnL ${isUp ? '+' : '-'}${formatRupiah(pnl24h!.abs())} (24 jam)',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One row per asset — total value held (from `asset_balances`, always
/// available) plus live price/24h change from CoinGecko (best-effort, may
/// be null for an unresolved asset name or a failed fetch — the row just
/// omits that part instead of showing a broken state). The avatar color is
/// deterministic per asset name so rows stay visually distinguishable at a
/// glance in a longer list.
class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.balance, required this.price});

  final AssetBalance balance;
  final CryptoPrice? price;

  static List<Color> get _palette => [
        AppColors.primary,
        AppColors.accent,
        const Color(0xFF0EA5A4),
        const Color(0xFF6366F1),
        const Color(0xFFE2B4BD),
      ];

  Color get _avatarColor => _palette[balance.asset.hashCode.abs() % _palette.length];

  String get _initials {
    final trimmed = balance.asset.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.length >= 2 ? trimmed.substring(0, 2).toUpperCase() : trimmed.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/investment/asset/${Uri.encodeComponent(balance.asset)}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: _avatarColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(color: _avatarColor, fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.asset,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    if (price != null) ...[
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              formatRupiah(price!.priceIdr),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                          if (price?.changePercent24h != null) ...[
                            const SizedBox(width: 6),
                            _ChangeBadge(percent: price!.changePercent24h!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        formatUsd(price!.priceUsd),
                        style: TextStyle(color: AppColors.textDisabled, fontSize: 11),
                      ),
                    ] else
                      Text(
                        'Harga tidak tersedia',
                        style: TextStyle(color: AppColors.textDisabled, fontSize: 11.5, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(balance.balance),
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                  ),
                  if (price != null && price!.priceIdr > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${formatCryptoQuantity(balance.balance / price!.priceIdr)}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                  if (price?.floatingPnl24h(balance.balance) != null) ...[
                    const SizedBox(height: 2),
                    _PnlText(amount: price!.floatingPnl24h(balance.balance)!),
                  ],
                  const SizedBox(height: 3),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "+Rp 45.000 (24j)" — floating P&L for this specific asset's holding,
/// see [CryptoPrice.floatingPnl24h].
class _PnlText extends StatelessWidget {
  const _PnlText({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final isUp = amount >= 0;
    final color = isUp ? AppColors.success : AppColors.error;
    return Text(
      'PnL ${isUp ? '+' : '-'}${formatRupiah(amount.abs())} (24j)',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final isUp = percent >= 0;
    final color = isUp ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 10, color: color),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyCryptoAccounts extends StatelessWidget {
  const _EmptyCryptoAccounts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.currency_bitcoin_rounded, color: AppColors.textSecondary, size: 32),
          SizedBox(height: 10),
          Text(
            'Belum ada akun crypto',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Tambah akun dengan provider bertipe Crypto lewat Portfolio, lalu top up '
            'saldonya lewat Transfer Antar Akun.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
