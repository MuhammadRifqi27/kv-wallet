import 'package:intl/intl.dart';

final _rupiahFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatRupiah(num amount) => _rupiahFormat.format(amount);

/// Masked stand-in for [formatRupiah] when the user has hidden nominal
/// values (e.g. dashboard privacy toggle) — fixed-width regardless of the
/// underlying amount so it doesn't leak the digit count.
String maskRupiah(num amount, {required bool hide}) => hide ? 'Rp ••••••' : formatRupiah(amount);

/// Hand-rolled instead of `DateFormat(pattern, 'id_ID')` — locale-aware
/// month names need `initializeDateFormatting()` first, which isn't wired
/// up anywhere yet; a fixed list is simpler for the handful of places that
/// need an Indonesian date label.
const _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];
const _monthNamesShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatIndonesianDate(DateTime date) => '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

String formatIndonesianDateShort(DateTime date) => '${date.day} ${_monthNamesShort[date.month - 1]}';

String monthName(int month) => _monthNames[month - 1];

String monthNameShort(int month) => _monthNamesShort[month - 1];

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
