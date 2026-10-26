import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One row shown on the in-app notification history page — mirrors what
/// was actually shown in the OS tray (title/body already localized at the
/// time it fired), not a re-derivation from live budget data.
class NotificationHistoryEntry {
  const NotificationHistoryEntry({required this.title, required this.body, required this.shownAt});

  factory NotificationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryEntry(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      shownAt: DateTime.tryParse(json['shownAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String title;
  final String body;
  final DateTime shownAt;

  Map<String, dynamic> toJson() => {'title': title, 'body': body, 'shownAt': shownAt.toIso8601String()};
}

/// Local, per-device log of notifications this app has shown — lets the
/// user revisit one after it's gone from the OS tray. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN G #43.
class NotificationHistoryService {
  static const _key = 'notification_history';

  /// Oldest entries beyond this count are dropped on write — this is a
  /// lightweight local log, not a full audit trail.
  static const _maxEntries = 30;

  Future<List<NotificationHistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((item) => NotificationHistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();
    entries.insert(0, NotificationHistoryEntry(title: title, body: body, shownAt: DateTime.now()));
    final trimmed = entries.take(_maxEntries).toList();
    await prefs.setStringList(_key, trimmed.map((entry) => jsonEncode(entry.toJson())).toList());
  }
}
