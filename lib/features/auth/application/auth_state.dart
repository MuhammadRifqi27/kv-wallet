import '../../../core/network/api_exception.dart';
import '../../../data/models/user_model.dart';

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final UserModel? user;
  final ApiException? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    ApiException? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
