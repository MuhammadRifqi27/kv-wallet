import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

/// Shared last step of turning biometric login on — used both by
/// ProfilePage's toggle (which already has a freshly re-confirmed PIN from
/// ConfirmPinSheet) and by the post-PIN-entry nudge on VerifyPinPage/
/// SetPinPage (which already has the just-typed, just-verified PIN in hand,
/// so it skips asking for it a second time). Callers are responsible for
/// getting a trustworthy plaintext [pin] first.
///
/// Returns `false` without changing anything if the OS prompt fails/is
/// cancelled; the caller decides what (if anything) to tell the user.
Future<bool> enrollBiometricLogin(WidgetRef ref, {required String pin, required String reason}) async {
  final authenticated = await ref.read(biometricServiceProvider).authenticate(reason);
  if (!authenticated) return false;

  await ref.read(secureStorageServiceProvider).saveCachedPin(pin);
  await ref.read(biometricPreferenceServiceProvider).setEnabled(true);
  ref.read(biometricEnabledProvider.notifier).state = true;
  return true;
}
