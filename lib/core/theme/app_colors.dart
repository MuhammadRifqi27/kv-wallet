import 'package:flutter/material.dart';

/// Flowr brand palette — dusty-rose accents anchored by a deep rose
/// interactive color, so buttons/spinners/focus states read as the same
/// hue family as the [primaryGradient] cards instead of a disconnected
/// neutral gray.
///
/// Dark-mode note: this class is used as a static namespace directly
/// (`AppColors.textPrimary`, etc.) across 45+ files rather than through
/// `Theme.of(context)`. Rewriting every call site was a much bigger change
/// than the value of dark mode justified, so instead each token that needs
/// to flip is a getter reading [_isDark] — one flag [FlowrApp.build] sets
/// once per frame, before it builds the rest of the tree. Flutter builds
/// top-down synchronously within a frame, so every descendant's `build()`
/// sees the value [FlowrApp] just set. Tokens that shouldn't flip (the
/// brand gradient and the dark text that sits on it, plus the semantic
/// success/error colors) stay plain `static const`, same as before.
class AppColors {
  AppColors._();

  static bool _isDark = false;
  static bool get isDark => _isDark;

  /// Called once per frame by `FlowrApp.build` — see class doc.
  static void updateBrightness(bool isDark) => _isDark = isDark;

  static Color get primary => _isDark ? _dark.primary : _light.primary;
  static Color get primaryLight => _isDark ? _dark.primaryLight : _light.primaryLight;
  static Color get background => _isDark ? _dark.background : _light.background;
  static Color get surface => _isDark ? _dark.surface : _light.surface;
  static Color get textPrimary => _isDark ? _dark.textPrimary : _light.textPrimary;
  static Color get textSecondary => _isDark ? _dark.textSecondary : _light.textSecondary;
  static Color get textDisabled => _isDark ? _dark.textDisabled : _light.textDisabled;
  static Color get border => _isDark ? _dark.border : _light.border;

  /// Text color used ON [primaryGradient] — that card is a fixed brand
  /// element in both themes, so its own palette doesn't flip either.
  static const Color primaryDark = Color(0xFF333333);

  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);

  static const List<Color> primaryGradient = [
    Color(0xFFE2B4BD),
    Color(0xFFF7D6D0),
  ];

  /// Palest tint from the same dusty-rose family — not wired into any
  /// token above, available for subtle section backgrounds.
  static const Color blushTint = Color(0xFFFFF5F5);
}

class _ColorSet {
  const _ColorSet({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;
}

const _light = _ColorSet(
  primary: Color(0xFF9E3A50),
  primaryLight: Color(0xFFF7D6D0),
  background: Color(0xFFF7F8FC),
  surface: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF1A1D29),
  textSecondary: Color(0xFF6B7280),
  textDisabled: Color(0xFFA1A6B4),
  border: Color(0xFFE5E7EB),
);

/// Deliberately not a pure-black/blue-gray dark theme — kept warm (a hint
/// of the brand's rose hue in the neutrals) so it still reads as the same
/// app instead of a generic dark template. [primary] is lightened from the
/// light theme's value since that deep rose (`#9E3A50`) is itself dark
/// enough to lose contrast against a near-black background when used as
/// plain text/icon color, not just as a button fill.
const _dark = _ColorSet(
  primary: Color(0xFFE58FA0),
  primaryLight: Color(0xFF3A2530),
  background: Color(0xFF14131A),
  surface: Color(0xFF1E1C24),
  textPrimary: Color(0xFFF2EDEF),
  textSecondary: Color(0xFFA8A2AC),
  textDisabled: Color(0xFF6E6874),
  border: Color(0xFF322F3A),
);
