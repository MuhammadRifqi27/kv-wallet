/// Heuristic parsing of ML Kit's raw OCR text into transaction-form
/// values — see docs/flutter-ocr-scan-struk-plan.txt BAGIAN 3 for the
/// reasoning behind each strategy. Pure functions (no I/O, no ML Kit
/// dependency) so they're unit-testable on plain strings.
library;

/// A run of digits with optional `.`/`,` thousand separators, e.g.
/// "25.000" or "25,000" or "25000". Rupiah amounts are always whole
/// numbers in this app (see formatters.dart), so separators are always
/// treated as thousand grouping, never a decimal point.
final _numberToken = RegExp(r'\d[\d.,]*\d|\d');

const _totalKeywords = ['grand total', 'total belanja', 'total bayar', 'jumlah bayar', 'total', 'jumlah'];

/// Finds the transaction total. Tries, in order:
/// 1. The last "total"-ish line that ISN'T a subtotal line (real totals
///    tend to appear after subtotal on a printed receipt).
/// 2. Any "total"-ish line at all, including subtotal, if that's all
///    there is.
/// 3. The largest plausible-looking Rupiah number (>= 4 digits) anywhere
///    in the receipt, on the assumption the total is usually the biggest
///    number printed.
/// Returns `null` if nothing usable was found — callers should leave the
/// amount field blank rather than guess 0.
double? parseAmountFromReceipt(String text) {
  final lines = text.split('\n');

  double? fromKeywordLines({required bool excludeSubtotal}) {
    // Reversed: the real total is usually the last "total"-labelled line
    // on the receipt (subtotal/discount lines come before it).
    for (final line in lines.reversed) {
      final lower = line.toLowerCase();
      if (!_totalKeywords.any(lower.contains)) continue;
      if (excludeSubtotal && (lower.contains('subtotal') || lower.contains('sub total'))) continue;

      final amount = _lastNumberIn(line);
      if (amount != null && amount > 0) return amount;
    }
    return null;
  }

  return fromKeywordLines(excludeSubtotal: true) ??
      fromKeywordLines(excludeSubtotal: false) ??
      _largestNumberIn(text);
}

final _dateToken = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})');

/// Finds the first `dd/mm/yyyy`-shaped date (also accepts `-`/`.` as
/// separators and a 2-digit year) — the format Indonesian receipts use.
/// Returns `null` if nothing valid is found; the caller falls back to
/// today's date, matching the form's existing default.
DateTime? parseDateFromReceipt(String text) {
  for (final match in _dateToken.allMatches(text)) {
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    var year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) continue;
    if (year < 100) year += 2000;
    if (month < 1 || month > 12) continue;
    if (day < 1 || day > 31) continue;
    if (year < 2000 || year > 2100) continue;

    try {
      final date = DateTime(year, month, day);
      // DateTime silently rolls over invalid days (e.g. 31 Feb -> Mar 3)
      // instead of throwing — reject anything that didn't round-trip.
      if (date.year == year && date.month == month && date.day == day) return date;
    } catch (_) {
      // Fall through to the next candidate match.
    }
  }
  return null;
}

/// Best-effort merchant name guess: the first non-empty line, since
/// store/restaurant names are almost always printed at the very top of a
/// receipt. Lines that don't look like a name at all (too short, or no
/// letters — a misread logo/border/asterisk divider, common right above
/// the store name on thermal receipts) are skipped rather than giving up
/// immediately, but only within the first few lines — past that we're
/// into the item list, and guessing a line item as the merchant name
/// would be worse than leaving the field blank.
String? parseDescriptionFromReceipt(String text) {
  const maxLinesToCheck = 5;
  var checked = 0;

  for (final rawLine in text.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (checked >= maxLinesToCheck) return null;
    checked++;

    final letterCount = line.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
    if (letterCount < 2) continue;

    return line.length > 60 ? line.substring(0, 60) : line;
  }
  return null;
}

/// Last numeric token on [line], normalized (separators stripped).
double? _lastNumberIn(String line) {
  final matches = _numberToken.allMatches(line).toList();
  if (matches.isEmpty) return null;
  return _normalize(matches.last.group(0)!);
}

/// Largest numeric token in [text] with at least 4 digits (>= 1000) —
/// filters out quantities/small line-item counts that aren't plausible
/// totals.
double? _largestNumberIn(String text) {
  double? largest;
  for (final match in _numberToken.allMatches(text)) {
    final raw = match.group(0)!;
    final digitCount = raw.replaceAll(RegExp(r'[.,]'), '').length;
    if (digitCount < 4) continue;
    final value = _normalize(raw);
    if (value != null && (largest == null || value > largest)) largest = value;
  }
  return largest;
}

double? _normalize(String token) => double.tryParse(token.replaceAll(RegExp(r'[.,]'), ''));
