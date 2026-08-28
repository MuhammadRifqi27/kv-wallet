import 'package:flutter/material.dart';

/// Flowr brand palette — dusty-rose accents anchored by a deep rose
/// interactive color, so buttons/spinners/focus states read as the same
/// hue family as the [primaryGradient] cards instead of a disconnected
/// neutral gray.
class AppColors {
  AppColors._();

  /// Deep, saturated shade of [primaryGradient]'s rose (`#E2B4BD`) — same
  /// hue, just darker/more saturated so it has enough contrast for white
  /// button text and reads as "interactive" rather than decorative.
  static const Color primary = Color(0xFF9E3A50);
  static const Color primaryDark = Color(0xFF333333);
  static const Color primaryLight = Color(0xFFF7D6D0);

  static const Color accent = Color(0xFFF59E0B);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFA1A6B4);

  static const Color border = Color(0xFFE5E7EB);
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
