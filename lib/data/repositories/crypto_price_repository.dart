import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/crypto_price_model.dart';

class _ResolvedCoin {
  const _ResolvedCoin({required this.id, required this.tickerSymbol});

  final String id;
  final String tickerSymbol;
}

/// CoinGecko's public API — no key needed for these endpoints, generous
/// free rate limit. Deliberately a standalone Dio instance (not
/// [ApiClient]): this is an unrelated third-party host, so it must not
/// carry our backend's bearer token or base URL.
class CryptoPriceRepository {
  CryptoPriceRepository() : _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10))) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: true));
    }
  }

  final Dio _dio;

  /// `asset` in this app is free-form text the user typed (see
  /// docs/mobile-api-reference.md: "string bebas yang diisi user sendiri"),
  /// which turned out in practice to be full names ("BITCOIN") rather than
  /// tickers ("BTC") — a fixed symbol→id map alone missed those entirely.
  /// Cached per app session (a query string is resolved once, not
  /// re-searched every time a price is needed).
  final Map<String, _ResolvedCoin?> _resolveCache = {};

  Future<_ResolvedCoin?> _resolve(String query) async {
    final key = query.trim().toUpperCase();
    if (key.isEmpty) return null;
    if (_resolveCache.containsKey(key)) return _resolveCache[key];

    // Fast path for common tickers — skips a network round-trip for the
    // overwhelmingly common case.
    final curatedId = cryptoSymbolToCoinGeckoId[key];
    if (curatedId != null) {
      return _resolveCache[key] = _ResolvedCoin(id: curatedId, tickerSymbol: key);
    }

    try {
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/search',
        queryParameters: {'query': query},
      );
      // CoinGecko's own search already ranks by relevance/market cap, so
      // the first hit is the right call for an ambiguous name like
      // "Bitcoin" (vs. some obscure token that also happens to be named
      // that) — same principle as picking the top web search result.
      final coins = (response.data as Map<String, dynamic>)['coins'] as List<dynamic>? ?? [];
      if (coins.isEmpty) return _resolveCache[key] = null;
      final first = coins.first as Map<String, dynamic>;
      final resolved = _ResolvedCoin(
        id: first['id'] as String,
        tickerSymbol: (first['symbol'] as String).toUpperCase(),
      );
      return _resolveCache[key] = resolved;
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[CryptoPriceRepository] resolve($query) failed: ${e.message}');
      return _resolveCache[key] = null;
    }
  }

  /// Looks up live IDR price + 24h change for each entry in [assets] that
  /// resolves to a known CoinGecko coin — anything that doesn't resolve is
  /// silently skipped rather than erroring the whole call, since this is
  /// supplementary price data, not core app data. Returns an empty map (not
  /// a thrown error) if the price request itself fails, for the same
  /// reason — a badge just doesn't show instead of blocking the Investment
  /// dashboard. Result is keyed by the original (uppercased) input string,
  /// matching how callers look values back up by `asset`.
  Future<Map<String, CryptoPrice>> getPrices(List<String> assets) async {
    final idToQuery = <String, String>{}; // coingecko id -> original asset string
    for (final asset in assets) {
      final resolved = await _resolve(asset);
      if (resolved != null) idToQuery[resolved.id] = asset.trim().toUpperCase();
    }
    if (idToQuery.isEmpty) return {};

    try {
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/simple/price',
        queryParameters: {
          'ids': idToQuery.keys.join(','),
          'vs_currencies': 'idr,usd',
          'include_24hr_change': 'true',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final result = <String, CryptoPrice>{};
      for (final entry in idToQuery.entries) {
        final priceJson = data[entry.key] as Map<String, dynamic>?;
        if (priceJson != null) {
          result[entry.value] = CryptoPrice.fromJson(priceJson);
        }
      }
      return result;
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[CryptoPriceRepository] getPrices failed: ${e.message}');
      return {};
    }
  }

  /// Real ticker symbol (e.g. `HYPE` for an entry the user typed as
  /// "HYPERLIQUID") — used to build a `BINANCE:{ticker}USDT` pair for the
  /// TradingView chart, which won't recognize the raw free-form name.
  /// Falls back to the input itself (uppercased) if resolution fails, so
  /// the chart still attempts *something* instead of showing nothing.
  Future<String> resolveTickerSymbol(String asset) async {
    final resolved = await _resolve(asset);
    return resolved?.tickerSymbol ?? asset.trim().toUpperCase();
  }

  /// Same as [getPrices] for a single asset, plus 7-day/30-day/3-month/
  /// 6-month/5-year % change (see [CryptoPrice.changePercent7d] and
  /// friends) from `/coins/{id}/market_chart` — one extra, heavier
  /// request, so this is only for a single-asset detail screen, not the
  /// dashboard's bulk list. Null if the asset doesn't resolve or the base
  /// price fetch fails; a failed *history* fetch specifically still
  /// returns the base price with the period fields left null (a missing
  /// period badge shouldn't hide the current price too).
  Future<CryptoPrice?> getExtendedPrice(String asset) async {
    final resolved = await _resolve(asset);
    if (resolved == null) return null;

    final base = (await getPrices([asset]))[asset.trim().toUpperCase()];
    if (base == null) return null;

    final periods = await _fetchPeriodChanges(resolved.id, base.priceIdr);
    return CryptoPrice(
      priceIdr: base.priceIdr,
      priceUsd: base.priceUsd,
      changePercent24h: base.changePercent24h,
      changePercent7d: periods?.pct7d,
      changePercent30d: periods?.pct30d,
      changePercent3m: periods?.pct3m,
      changePercent6m: periods?.pct6m,
      changePercent5y: periods?.pct5y,
    );
  }

  Future<_PeriodChanges?> _fetchPeriodChanges(String coinId, double currentPriceIdr) async {
    try {
      // No explicit `interval` — CoinGecko auto-picks granularity for the
      // free tier (daily, for a range this wide) based on `days` alone;
      // requesting a specific interval is a paid-plan-only parameter.
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/coins/$coinId/market_chart',
        queryParameters: {'vs_currency': 'idr', 'days': '1825'},
      );
      final prices = (response.data as Map<String, dynamic>)['prices'] as List<dynamic>? ?? [];
      if (prices.isEmpty) return null;

      final now = DateTime.now();
      double? priceAt(int daysAgo) {
        final targetMs = now.subtract(Duration(days: daysAgo)).millisecondsSinceEpoch;
        // `prices` is ascending by timestamp — first point at/after the
        // target is the closest available snapshot to "N days ago". If the
        // coin's whole history is younger than the target (e.g. a coin
        // listed 2 years ago, asked for 5y-ago), every point is already
        // >= target and this returns the very first (oldest) one instead —
        // see [CryptoPrice.changePercent5y]'s doc comment.
        for (final point in prices) {
          final ts = (point as List)[0] as num;
          if (ts >= targetMs) return (point[1] as num).toDouble();
        }
        return ((prices.last as List)[1] as num).toDouble();
      }

      double? pctChange(double? past) {
        if (past == null || past == 0) return null;
        return (currentPriceIdr - past) / past * 100;
      }

      return _PeriodChanges(
        pct7d: pctChange(priceAt(7)),
        pct30d: pctChange(priceAt(30)),
        pct3m: pctChange(priceAt(90)),
        pct6m: pctChange(priceAt(180)),
        pct5y: pctChange(priceAt(365 * 5)),
      );
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[CryptoPriceRepository] period changes for $coinId failed: ${e.message}');
      return null;
    }
  }
}

class _PeriodChanges {
  const _PeriodChanges({this.pct7d, this.pct30d, this.pct3m, this.pct6m, this.pct5y});

  final double? pct7d;
  final double? pct30d;
  final double? pct3m;
  final double? pct6m;
  final double? pct5y;
}
