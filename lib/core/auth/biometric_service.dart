import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` — fingerprint/Face ID unlock only
/// (`biometricOnly: true`), not device-credential fallback (PIN/pattern/
/// password), since this app already has its own PIN app-lock; letting the
/// OS credential double as a bypass would make that redundant.
class BiometricService {
  BiometricService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Whether this device even has the hardware/enrollment for it. Wrapped
  /// in try/catch — some devices throw instead of returning false for
  /// unsupported configurations.
  Future<bool> isSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return canCheck && deviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns `false` (never throws) for any failure — wrong biometric, no
  /// biometric enrolled, user cancels, hardware error, etc. Callers can't
  /// tell those apart, which is fine: every case has the same fallback,
  /// "let the user type their PIN instead."
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
