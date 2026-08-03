import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/core_providers.dart';
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

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    try {
      final user = await _ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
            deviceName: 'KVWallet Mobile',
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
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, clearError: true);
    try {
      await _ref.read(authRepositoryProvider).register(name: name, email: email, password: password);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, error: e);
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true, clearUser: true);
  }

  /// Invoked by [ApiClient] when a request comes back 401 — token is already
  /// cleared from storage at that point, this just syncs UI state.
  void forceLogout() {
    state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true, clearUser: true);
  }
}
