import 'package:shared_preferences/shared_preferences.dart';

/// Whether this DEVICE has seen the welcome/onboarding slides — deliberately
/// per-device (SharedPreferences), not tied to the user's account, so a
/// fresh install always shows it once and an existing account logging in on
/// a new device sees the app intro too, no backend involved.
class OnboardingService {
  static const _key = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
