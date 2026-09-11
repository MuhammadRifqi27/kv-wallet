import 'package:shared_preferences/shared_preferences.dart';

/// Whether this DEVICE has biometric login turned on — deliberately
/// per-device (SharedPreferences), same reasoning as [OnboardingService]:
/// it's a convenience toggle for unlocking this specific installation, not
/// an account-wide setting synced from the backend.
class BiometricPreferenceService {
  static const _key = 'biometric_login_enabled';

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
