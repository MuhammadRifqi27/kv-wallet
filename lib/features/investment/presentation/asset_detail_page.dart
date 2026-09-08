import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/btc_tracking_model.dart';
import '../../../data/models/crypto_price_model.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/tradingview_chart.dart';
import '../application/btc_tracking_controller.dart';
import '../application/crypto_price_controller.dart';

/// Opened by tapping an asset row on the Investment dashboard. Shows the
/// live price/chart for the *asset itself* (market data, from CoinGecko +
/// a TradingView chart widget) up top, then which of the user's own
/// accounts hold it and how much — the per-account split
/// [computePortfolioBalancesForAsset] computes client-side, since
/// `GET /btc-tracking` only gives a global total per asset.
///
/// Layout note: the chart is a normal item inside the page's one
/// `ListView`, not pinned in a fixed area above it — an earlier version
/// tried pinning it (to dodge the WebView/page gesture conflict below by
/// keeping the chart out of any `Scrollable`'s hit-test area entirely),
/// but a fixed-height chart permanently eats screen space regardless of
/// scroll position, leaving very little room for everything below it on
/// most phones. The gesture conflict is solved a different way instead —
/// see `TradingViewChart`'s `gestureRecognizers` comment: it only claims
/// horizontal drag + pinch (how a candlestick chart is actually panned/
/// zoomed), so a vertical swipe that starts on the chart still scrolls
/// this page normally.
class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(singleAssetPriceProvider(asset));
    final tickerAsync = ref.watch(assetTickerProvider(asset));
    final overviewAsync = ref.watch(btcOverviewControllerProvider);
    final activityAsync = ref.watch(btcActivityControllerProvider);

    final totalHeld = overviewAsync.valueOrNull?.assetBalances
        .where((b) => b.asset.toUpperCase() == asset.toUpperCase())
        .firstOrNull
        ?.balance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(asset)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          priceAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (price) => price == null
                ? const _NoPriceNotice()
                : _PriceHeader(
                    priceIdr: price.priceIdr,
                    priceUsd: price.priceUsd,
                    changePercent: price.changePercent24h,
                  ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
              // Falls back to the raw (possibly full-name) asset string
              // while the real ticker is still resolving — TradingView
              // just won't find a matching pair for that brief window.
              child: TradingViewChart(symbol: tickerAsync.valueOrNull ?? asset),
            ),
          ),
          const SizedBox(height: 16),
          if (totalHeld != null) ...[
            _HoldingSummaryCard(totalIdr: totalHeld, price: priceAsync.valueOrNull),
            const SizedBox(height: 16),
          ],
          priceAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (price) {
              if (price == null || totalHeld == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PerformanceCard(price: price, totalHeldIdr: totalHeld),
              );
            },
          ),
          const Text(
            'Dipegang di Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dihitung dari riwayat aktivitas — lihat catatan di kode kalau angkanya tampak meleset.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final overview = overviewAsync.valueOrNull;
              final activity = activityAsync.valueOrNull;
              if (overview == null || activity == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: AppLoadingIndicator()),
                );
              }
              return _HoldingsList(
                asset: asset,
                overview: overview,
                activity: activity,
                price: priceAsync.valueOrNull,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriceHeader extends StatelessWidget {
  const _PriceHeader({required this.priceIdr, required this.priceUsd, required this.changePercent});

  final double priceIdr;
  final double priceUsd;
  final double? changePercent;

  @override
  Widget build(BuildContext context) {
    final isUp = (changePercent ?? 0) >= 0;
    final color = isUp ? AppColors.success : AppColors.error;

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
            'Harga Saat Ini',
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(priceIdr),
                style: const TextStyle(color: AppColors.primaryDark, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              if (changePercent != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 13, color: color),
                      const SizedBox(width: 2),
                      Text(
                        '${changePercent!.abs().toStringAsFixed(1)}% (24 jam)',
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatUsd(priceUsd),
            style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.65), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// "You hold ≈ X coins" — the coin quantity implied by the Rupiah value
/// currently held, converted at today's market price. Not a stored
/// quantity (BTC Tracking only ever records Rupiah amounts, never units),
/// so this is an estimate: it answers "what does my balance mean in coin
/// terms right now", not "exactly how many coins did each purchase get".
class _HoldingSummaryCard extends StatelessWidget {
  const _HoldingSummaryCard({required this.totalIdr, required this.price});

  final double totalIdr;
  final CryptoPrice? price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Anda Miliki',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(totalIdr),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15),
                ),
              ],
            ),
          ),
          if (price != null && price!.priceIdr > 0)
            Text(
              '≈ ${formatCryptoQuantity(totalIdr / price!.priceIdr)} BTC',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14),
            ),
        ],
      ),
    );
  }
}

/// Floating P&L across 6 windows (24 jam/1 minggu/1 bulan/3 bulan/6 bulan/
/// 5 tahun) for the position currently held — see [CryptoPrice.floatingPnl24h]
/// and friends for what this can/can't tell you (price-movement reaction on
/// today's position, not P&L vs. what you originally paid).
class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.price, required this.totalHeldIdr});

  final CryptoPrice price;
  final double totalHeldIdr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performa (Floating PnL)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _PerformanceRow(
            label: '24 Jam',
            percent: price.changePercent24h,
            pnl: price.floatingPnl24h(totalHeldIdr),
          ),
          const Divider(height: 20, color: AppColors.border),
          _PerformanceRow(
            label: '1 Minggu',
            percent: price.changePercent7d,
            pnl: price.floatingPnl7d(totalHeldIdr),
          ),
          const Divider(height: 20, color: AppColors.border),
          _PerformanceRow(
            label: '1 Bulan',
            percent: price.changePercent30d,
            pnl: price.floatingPnl30d(totalHeldIdr),
          ),
          const Divider(height: 20, color: AppColors.border),
          _PerformanceRow(
            label: '3 Bulan',
            percent: price.changePercent3m,
            pnl: price.floatingPnl3m(totalHeldIdr),
          ),
          const Divider(height: 20, color: AppColors.border),
          _PerformanceRow(
            label: '6 Bulan',
            percent: price.changePercent6m,
            pnl: price.floatingPnl6m(totalHeldIdr),
          ),
          const Divider(height: 20, color: AppColors.border),
          _PerformanceRow(
            label: '5 Tahun',
            percent: price.changePercent5y,
            pnl: price.floatingPnl5y(totalHeldIdr),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.label, required this.percent, required this.pnl});

  final String label;
  final double? percent;
  final double? pnl;

  @override
  Widget build(BuildContext context) {
    if (percent == null || pnl == null) {
      return Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const Text('Data tidak tersedia', style: TextStyle(color: AppColors.textDisabled, fontSize: 12)),
        ],
      );
    }

    final isUp = percent! >= 0;
    final color = isUp ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isUp ? '+' : '-'}${formatRupiah(pnl!.abs())}',
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 10, color: color),
                Text(
                  '${percent!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _NoPriceNotice extends StatelessWidget {
  const _NoPriceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Harga pasar untuk aset ini belum tersedia.',
              style: TextStyle(color: AppColors.primaryDark, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldingsList extends StatelessWidget {
  const _HoldingsList({required this.asset, required this.overview, required this.activity, required this.price});

  final String asset;
  final BtcOverview overview;
  final List<BtcActivityItem> activity;
  final CryptoPrice? price;

  @override
  Widget build(BuildContext context) {
    final balances = computePortfolioBalancesForAsset(activity, asset);
    final entries = balances.entries.where((e) => e.value.abs() > 0.01).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Belum ada saldo tercatat untuk aset ini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: [
        for (final entry in entries) ...[
          _HoldingTile(
            accountName: overview.portfolios.where((p) => p.id == entry.key).firstOrNull?.accountName ??
                'Akun #${entry.key}',
            amount: entry.value,
            price: price,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({required this.accountName, required this.amount, required this.price});

  final String accountName;
  final double amount;
  final CryptoPrice? price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              accountName,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(amount),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
              ),
              if (price != null && price!.priceIdr > 0)
                Text(
                  '≈ ${formatCryptoQuantity(amount / price!.priceIdr)} BTC',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
