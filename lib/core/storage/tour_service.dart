import 'package:shared_preferences/shared_preferences.dart';

/// Whether this DEVICE has seen the interactive feature tour — mirrors
/// [OnboardingService]'s per-device (not per-account) persistence exactly,
/// see that class's doc comment for the rationale. Separate flag/key from
/// onboarding since this tour is a distinct feature (spotlight tour of the
/// Dashboard/nav, shown after landing in the app) — see
/// docs/plan-dev/onboarding-tour-plan.txt.
class TourService {
  static const _key = 'has_seen_feature_tour';

  Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
