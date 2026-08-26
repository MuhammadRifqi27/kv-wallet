import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../pin/application/pin_controller.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> checkAuthStatus() async {
    try {
      final user = await _ref.read(authRepositoryProvider).currentUser();
      state = user != null
          ? state.copyWith(status: AuthStatus.authenticated, user: user)
          : state.copyWith(status: AuthStatus.unauthenticated);
    } on ApiException {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String login, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(
            login: login,
            password: password,
            deviceName: 'Flowr Mobile',
          );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).register(
            name: name,
            username: username,
            email: email,
            password: password,
            deviceName: 'Flowr Mobile',
          );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e);
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true, clearUser: true);
    // Otherwise a different user logging in on the same device (without an
    // app restart) would inherit the previous session's unlocked PIN gate.
    _ref.read(pinVerifiedProvider.notifier).state = false;
  }

  /// Invoked by [ApiClient] when a request comes back 401 — token is already
  /// cleared from storage at that point, this just syncs UI state.
  void forceLogout() {
    state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true, clearUser: true);
    _ref.read(pinVerifiedProvider.notifier).state = false;
  }

  /// Re-fetches `/auth/me` to pick up server-side changes that happened
  /// mid-session — e.g. admin marks a membership payment verified, which
  /// updates `money_management_permissions` but doesn't push anything to
  /// the app on its own. Call this at natural check-in points (like the
  /// membership status check) instead of forcing a full re-login.
  Future<void> refreshUser() async {
    try {
      final user = await _ref.read(authRepositoryProvider).currentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } on ApiException {
      // Keep the cached user on failure — a 401 already triggers
      // forceLogout() via the ApiClient interceptor on its own.
    }
  }

  /// Updates the cached user's `hasPin` locally right after a successful
  /// `POST /auth/pin`, so the router redirect (which reads it synchronously)
  /// doesn't need to wait on a fresh `/auth/me` round-trip.
  void markPinSet() {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(user: user.copyWith(hasPin: true));
  }
}
