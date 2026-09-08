/// Ticker symbol (`BTC`, `ETH`, ...) → CoinGecko coin id, for the handful
/// of assets a typical user would actually track — CoinGecko's full
/// `/coins/list` has 10k+ entries with ambiguous/duplicate symbols, so a
/// small curated map is simpler and safer than resolving symbols
/// dynamically. An asset outside this map just shows no price/chart data
/// instead of guessing wrong.
const cryptoSymbolToCoinGeckoId = {
  'BTC': 'bitcoin',
  'ETH': 'ethereum',
  'HYPE': 'hyperliquid',
  'USDT': 'tether',
  'USDC': 'usd-coin',
  'BNB': 'binancecoin',
  'SOL': 'solana',
  'XRP': 'ripple',
  'ADA': 'cardano',
  'DOGE': 'dogecoin',
  'TON': 'the-open-network',
  'TRX': 'tron',
  'AVAX': 'avalanche-2',
  'DOT': 'polkadot',
  'MATIC': 'matic-network',
  'LINK': 'chainlink',
  'LTC': 'litecoin',
  'SHIB': 'shiba-inu',
  'BCH': 'bitcoin-cash',
  'XLM': 'stellar',
  'ATOM': 'cosmos',
};

/// Live price snapshot for one asset — from CoinGecko's `/simple/price`
/// (`vs_currencies=idr,usd`, `include_24hr_change=true`). `changePercent24h`
/// null means CoinGecko didn't return a change figure (rare, but possible
/// for illiquid coins) — read off the `idr` pair; USD's own 24h change is
/// close enough to identical for display purposes that tracking both
/// separately isn't worth it.
class CryptoPrice {
  const CryptoPrice({
    required this.priceIdr,
    required this.priceUsd,
    this.changePercent24h,
    this.changePercent7d,
    this.changePercent30d,
    this.changePercent3m,
    this.changePercent6m,
    this.changePercent5y,
  });

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    return CryptoPrice(
      priceIdr: (json['idr'] as num?)?.toDouble() ?? 0,
      priceUsd: (json['usd'] as num?)?.toDouble() ?? 0,
      changePercent24h: (json['idr_24h_change'] as num?)?.toDouble(),
    );
  }

  final double priceIdr;
  final double priceUsd;
  final double? changePercent24h;

  /// From `/coins/{id}/market_chart` (a separate, heavier fetch than the
  /// `/simple/price` call that fills everything else above) — only
  /// populated by [CryptoPriceRepository.getExtendedPrice], which the
  /// Asset Detail page uses. Left null by the plain `getPrices()` the
  /// Investment dashboard's list uses, to keep that bulk call cheap (one
  /// extra network round-trip per *held* asset is fine on-demand for a
  /// single detail screen; doing that for every row on every dashboard
  /// load would burn through CoinGecko's public rate limit fast).
  final double? changePercent7d;
  final double? changePercent30d;
  final double? changePercent3m;
  final double? changePercent6m;

  /// "5 years ago" if the coin has been listed that long — otherwise the
  /// earliest price CoinGecko has for it, so this quietly becomes "change
  /// since listing" for newer coins rather than a true 5-year figure. Good
  /// enough for a rough long-view badge; not precise history analysis.
  final double? changePercent5y;

  bool get isUp => (changePercent24h ?? 0) >= 0;

  double? _floatingPnl(double currentValueIdr, double? pct) {
    if (pct == null) return null;
    return currentValueIdr * pct / (100 + pct);
  }

  /// Floating P&L over the last 24h for a position currently worth
  /// [currentValueIdr] — derived from [changePercent24h], *not* a stored
  /// figure: `GET /btc-tracking` has no cost-basis/purchase-price data at
  /// all (its ledger only ever records Rupiah amounts moved in/out, never
  /// "bought at price X"), so this can only ever answer "what did today's
  /// price move do to my current position", not "am I up or down from what
  /// I originally paid". Math: if `pct` is the % change over the period,
  /// value at the start of that period was `currentValueIdr / (1 +
  /// pct/100)` (assuming the quantity held hasn't changed in that window)
  /// — this returns the difference. Same caveat applies to
  /// [floatingPnl7d]/[floatingPnl30d]/[floatingPnl3m]/[floatingPnl6m]/
  /// [floatingPnl5y] below.
  double? floatingPnl24h(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent24h);

  double? floatingPnl7d(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent7d);

  double? floatingPnl30d(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent30d);

  double? floatingPnl3m(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent3m);

  double? floatingPnl6m(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent6m);

  double? floatingPnl5y(double currentValueIdr) => _floatingPnl(currentValueIdr, changePercent5y);
}
