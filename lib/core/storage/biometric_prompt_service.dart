import 'package:shared_preferences/shared_preferences.dart';

/// How many times we've offered the "enable biometric login?" nudge (see
/// `maybeShowBiometricEnablePrompt`) on this device — capped at
/// [maxPromptCount] so it eventually stops asking someone who keeps
/// declining, instead of nagging on every single PIN entry forever.
class BiometricPromptService {
  static const _key = 'biometric_prompt_shown_count';
  static const maxPromptCount = 3;

  Future<int> getShownCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> incrementShownCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    await prefs.setInt(_key, current + 1);
  }
}
