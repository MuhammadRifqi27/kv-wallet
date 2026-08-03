import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/splash/presentation/splash_page.dart';

/// Bridges Riverpod state changes into something [GoRouter]'s
/// `refreshListenable` understands, so login/logout re-triggers redirects.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefresh(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final onAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      switch (status) {
        case AuthStatus.unknown:
          return onSplash ? null : '/splash';
        case AuthStatus.authenticating:
          // Transient loading state while login/register is in flight —
          // stay put so the current page can show its own spinner instead
          // of bouncing through Splash mid-request.
          return null;
        case AuthStatus.authenticated:
          return (onAuthPage || onSplash) ? '/home' : null;
        case AuthStatus.unauthenticated:
          return onAuthPage ? null : '/login';
      }
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );
});
