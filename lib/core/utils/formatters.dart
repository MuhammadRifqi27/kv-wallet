import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatRupiah(num amount) => _rupiahFormat.format(amount);

final _usdFormat = NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);

/// Crypto prices need cents (a $0 vs $0.03 coin looks identical otherwise,
/// unlike Rupiah amounts which are never fractional in this app).
String formatUsd(num amount) => _usdFormat.format(amount);

final _cryptoQuantityFormat = NumberFormat('#,##0.########', 'en_US');

/// Coin quantity implied by a Rupiah value at a given price (e.g. "you hold
/// ~0.00601917 BTC") — up to 8 decimal places, trailing zeros trimmed, since
/// unlike Rupiah, fractional coin amounts are the norm, not an edge case.
String formatCryptoQuantity(double quantity) => _cryptoQuantityFormat.format(quantity);

/// Masked stand-in for [formatRupiah] when the user has hidden nominal
/// values (e.g. dashboard privacy toggle) — fixed-width regardless of the
/// underlying amount so it doesn't leak the digit count.
String maskRupiah(num amount, {required bool hide}) => hide ? 'Rp ••••••' : formatRupiah(amount);

/// Hand-rolled instead of `DateFormat(pattern, locale)` — locale-aware
/// month names via `intl` need `initializeDateFormatting()` first, which
/// isn't wired up anywhere; a fixed id/en lookup is simpler for the
/// handful of places that need a localized month name. Every call site
/// passes the current `Locale` (`Localizations.localeOf(context)`) so the
/// name follows the user's language picker — see
/// docs/plan-dev/multi-bahasa-plan.txt.
const _monthNamesId = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _monthNamesShortId = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];
const _monthNamesEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _monthNamesShortEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

List<String> _monthNamesFor(Locale locale) => locale.languageCode == 'en' ? _monthNamesEn : _monthNamesId;

List<String> _monthNamesShortFor(Locale locale) => locale.languageCode == 'en' ? _monthNamesShortEn : _monthNamesShortId;

String formatLocalizedDate(DateTime date, Locale locale) =>
    '${date.day} ${_monthNamesFor(locale)[date.month - 1]} ${date.year}';

String formatLocalizedDateShort(DateTime date, Locale locale) =>
    '${date.day} ${_monthNamesShortFor(locale)[date.month - 1]}';

String monthName(int month, Locale locale) => _monthNamesFor(locale)[month - 1];

String monthNameShort(int month, Locale locale) => _monthNamesShortFor(locale)[month - 1];

/// Compact Rupiah for tight spaces (chart axis labels) — "jt" (juta) and
/// "rb" (ribu) instead of the full "Rp 5.000.000" `formatRupiah` gives.
String formatCompactRupiah(num amount) {
  final value = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (value >= 1000000000) return '$sign${(value / 1000000000).toStringAsFixed(1)}M';
  if (value >= 1000000) return '$sign${(value / 1000000).toStringAsFixed(1)}jt';
  if (value >= 1000) return '$sign${(value / 1000).toStringAsFixed(0)}rb';
  return '$sign${value.toStringAsFixed(0)}';
}
