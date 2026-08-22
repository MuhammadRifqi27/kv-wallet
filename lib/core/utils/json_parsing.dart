/// Defensive JSON helpers for endpoints whose exact response shape isn't
/// documented with a sample payload (Dashboard, Summary) — fall back to a
/// safe default instead of throwing, so one unexpected/renamed field
/// doesn't crash an entire multi-section page.
library;

double parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime? parseDate(Object? value) {
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<dynamic> parseList(Object? value) => value is List ? value : const [];

/// Handles a bare JSON array, Laravel's default paginator envelope
/// (`{"data": [...], "current_page": ..., ...}`), and /transactions'
/// double-wrapped shape (`{"data": {"data": [...], ...paginator}, "summary": {...}}`)
/// — recurses through nested `data` keys until it finds the actual array.
List<dynamic> parseListResponse(Object? data) {
  if (data is List) return data;
  if (data is Map && data.containsKey('data')) return parseListResponse(data['data']);
  return const [];
}

/// Reads a label out of a field that might be a nested object (`{"name": ...}`)
/// or a flat string, trying each candidate key in turn.
String parseLabel(Map<String, dynamic> json, List<String> keys, {String fallback = '-'}) {
  for (final key in keys) {
    final raw = json[key];
    if (raw is Map) {
      final name = raw['name'];
      if (name is String) return name;
    } else if (raw is String) {
      return raw;
    }
  }
  return fallback;
}
