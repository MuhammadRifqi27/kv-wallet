import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/application/auth_controller.dart';

/// Whether the PIN has been verified for the CURRENT app session. In-memory
/// only (no persistence) so it resets to false on every cold start — that
/// reset is exactly what makes /pin/verify act as an app-lock screen.
final pinVerifiedProvider = StateProvider<bool>((ref) => false);

class PinState {
  const PinState({this.isLoading = false, this.error});

  final bool isLoading;
  final ApiException? error;

  PinState copyWith({bool? isLoading, ApiException? error, bool clearError = false}) {
    return PinState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final pinControllerProvider = StateNotifierProvider<PinController, PinState>((ref) {
  return PinController(ref);
});

class PinController extends StateNotifier<PinState> {
  PinController(this._ref) : super(const PinState());

  final Ref _ref;

  Future<bool> setPin({required String pin, required String pinConfirmation}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(pinRepositoryProvider).setPin(pin: pin, pinConfirmation: pinConfirmation);
      _ref.read(authControllerProvider.notifier).markPinSet();
      _ref.read(pinVerifiedProvider.notifier).state = true;
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  /// Changing an existing PIN (requires proof of the old one) — distinct
  /// from [setPin], which is only for the first-time, no-PIN-yet case and
  /// also flips [pinVerifiedProvider]/`markPinSet` for the app-lock gate.
  /// Those don't apply here since the user is already past that gate.
  Future<bool> changePin({required String currentPin, required String pin, required String pinConfirmation}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(pinRepositoryProvider).changePin(currentPin: currentPin, pin: pin, pinConfirmation: pinConfirmation);
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }

  Future<bool> verifyPin({required String pin}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(pinRepositoryProvider).verifyPin(pin: pin);
      _ref.read(pinVerifiedProvider.notifier).state = true;
      state = state.copyWith(isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }
}
