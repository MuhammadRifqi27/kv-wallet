import 'package:shared_preferences/shared_preferences.dart';

/// Whether this DEVICE wants budget notifications (near-limit/over-budget)
/// — per-device like [BiometricPreferenceService], defaults to on. See
/// docs/ide-improvement-fitur-existing.txt BAGIAN G #43.
class NotificationPreferenceService {
  static const _key = 'budget_notifications_enabled';

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
