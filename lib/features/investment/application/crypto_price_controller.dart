import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/models/crypto_price_model.dart';
import 'btc_tracking_controller.dart';

/// Live prices for every asset the user actually holds (per
/// [btcOverviewControllerProvider]'s `asset_balances`) — re-fetches
/// whenever that list changes. Supplementary data: a failed/partial fetch
/// just means missing badges, never blocks the Investment dashboard from
/// showing (see CryptoPriceRepository.getPrices).
final assetPricesProvider = FutureProvider.autoDispose<Map<String, CryptoPrice>>((ref) async {
  final overview = await ref.watch(btcOverviewControllerProvider.future);
  final symbols = overview.assetBalances.map((b) => b.asset).toList();
  return ref.read(cryptoPriceRepositoryProvider).getPrices(symbols);
});

/// Live price + 24h/7d/30d/5y change for a single asset — used by the
/// Asset Detail page. Deliberately not shared with [assetPricesProvider]:
/// the 7d/30d/5y figures cost an extra CoinGecko request per asset (see
/// CryptoPriceRepository.getExtendedPrice), which is fine for one asset on
/// its own detail screen but too expensive to do for every row on the
/// dashboard's bulk list.
final singleAssetPriceProvider = FutureProvider.autoDispose.family<CryptoPrice?, String>((ref, asset) {
  return ref.read(cryptoPriceRepositoryProvider).getExtendedPrice(asset);
});

/// Real ticker (e.g. `HYPE` for an entry typed as "HYPERLIQUID") for the
/// TradingView chart — see [CryptoPriceRepository.resolveTickerSymbol].
final assetTickerProvider = FutureProvider.autoDispose.family<String, String>((ref, asset) {
  return ref.read(cryptoPriceRepositoryProvider).resolveTickerSymbol(asset);
});
