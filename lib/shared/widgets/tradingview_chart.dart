import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';

/// Embeds TradingView's public "Advanced Chart" widget (no API key —
/// TradingView doesn't offer a data API for third parties, only this
/// embeddable widget; see docs discussion in the Investment feature). Pass
/// a plain asset symbol like `BTC`; it's mapped to a Binance USDT pair
/// (`BINANCE:BTCUSDT`) since that's the most common quote available for
/// most coins — the chart may come back empty for an asset that isn't
/// actually listed there.
class TradingViewChart extends StatefulWidget {
  const TradingViewChart({super.key, required this.symbol, this.height = 440});

  final String symbol;
  final double height;

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;

  /// Guards against re-loading the HTML on every dependency change —
  /// [didChangeDependencies] (unlike [initState]) also fires whenever an
  /// ancestor InheritedWidget changes, not just once.
  bool _loadedInitialHtml = false;

  @override
  void initState() {
    super.initState();
    // AppColors.isDark reflects the theme FlowrApp.build resolved for this
    // frame (see that class's doc comment) — read once here at load time.
    // The chart doesn't need to react to a LATER theme change while still
    // mounted: this widget only ever appears on AssetDetailPage, a pushed
    // (non-kept-alive) route reached from a different tab than Profile's
    // theme toggle, so reaching it again after switching themes always
    // means a fresh push (and therefore a fresh initState) with the
    // current theme already correct. See
    // docs/ide-improvement-fitur-existing.txt BAGIAN C #13.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surface);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `Localizations.localeOf` needs a fully-established InheritedWidget
    // chain — unlike AppColors.isDark above, it can't be read safely from
    // initState. See docs/ide-improvement-fitur-existing.txt BAGIAN B #10.
    if (!_loadedInitialHtml) {
      _loadedInitialHtml = true;
      _controller.loadHtmlString(_html(widget.symbol, Localizations.localeOf(context)));
    }
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _controller.loadHtmlString(_html(widget.symbol, Localizations.localeOf(context)));
    }
  }

  /// `#rrggbb` for TradingView's `toolbar_bg` JS config, which only takes a
  /// plain hex string.
  static String _toHex(Color color) => '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  String _html(String symbol, Locale locale) {
    final tvSymbol = 'BINANCE:${symbol.toUpperCase()}USDT';
    final tvTheme = AppColors.isDark ? 'dark' : 'light';
    final tvLocale = locale.languageCode == 'en' ? 'en' : 'id';
    final toolbarBg = _toHex(AppColors.surface);
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin: 0; padding: 0; width: 100%; height: 100%; }
    /* TradingView's "autosize" fills its *containing div's* box — without
       an explicit height chain all the way down, that div collapses to 0
       and the widget renders squashed into whatever sliver is left. */
    .tradingview-widget-container, #tv_chart { width: 100%; height: 100%; }
  </style>
</head>
<body>
  <div class="tradingview-widget-container">
    <div id="tv_chart"></div>
    <script src="https://s3.tradingview.com/tv.js"></script>
    <script>
      new TradingView.widget({
        "autosize": true,
        "symbol": "$tvSymbol",
        "interval": "D",
        "timezone": "Asia/Jakarta",
        "theme": "$tvTheme",
        "style": "1",
        "locale": "$tvLocale",
        "toolbar_bg": "$toolbarBg",
        "enable_publishing": false,
        "hide_top_toolbar": false,
        "hide_legend": false,
        "save_image": false,
        "container_id": "tv_chart"
      });
    </script>
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      // Without this, drag/pinch gestures that start on the chart get
      // claimed by the ancestor ListView's Scrollable instead of reaching
      // the WebView — the page loads fine, but panning/zooming the chart
      // itself doesn't respond (it's not a TradingView limitation, it's
      // Flutter's gesture arena picking the outer scroll by default when a
      // PlatformView sits inside a scrollable). Claiming these recognizers
      // here lets the WebView's own touch handling — and so the chart's
      // internal JS pan/zoom — receive the gesture instead.
      //
      // Deliberately *not* claiming VerticalDragGestureRecognizer: this
      // widget lives inline in a vertically-scrolling page (see
      // AssetDetailPage), and a candlestick chart is panned/zoomed
      // horizontally + via pinch anyway — claiming only those two lets a
      // vertical swipe that starts on the chart still scroll the page
      // normally instead of the chart eating it. Claiming all three (an
      // earlier version of this fix) solved the "can't pan the chart"
      // complaint but traded it for "can't scroll the page from on top of
      // the chart" — this split avoids re-introducing that.
      child: WebViewWidget(
        controller: _controller,
        gestureRecognizers: {
          Factory<HorizontalDragGestureRecognizer>(HorizontalDragGestureRecognizer.new),
          Factory<ScaleGestureRecognizer>(ScaleGestureRecognizer.new),
        },
      ),
    );
  }
}
