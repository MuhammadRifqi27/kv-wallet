import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadHtmlString(_html(widget.symbol));
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _controller.loadHtmlString(_html(widget.symbol));
    }
  }

  String _html(String symbol) {
    final tvSymbol = 'BINANCE:${symbol.toUpperCase()}USDT';
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
        "theme": "light",
        "style": "1",
        "locale": "id",
        "toolbar_bg": "#f7f8fc",
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
