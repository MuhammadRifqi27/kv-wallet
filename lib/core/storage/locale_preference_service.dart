import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted per-device (SharedPreferences), same reasoning as
/// [ThemePreferenceService] — display preference, not an account setting
/// synced from the backend. `null` means "ikuti sistem" (follow the
/// device's own locale, falling back to Indonesian if the device locale
/// isn't `id`/`en` — see [AppLocalizations.supportedLocales]).
class LocalePreferenceService {
  static const _key = 'app_locale';

  Future<Locale?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
