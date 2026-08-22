import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/portfolio_model.dart';
import '../data/models/transaction_model.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/master_data/presentation/category_list_page.dart';
import '../features/master_data/presentation/investment_list_page.dart';
import '../features/master_data/presentation/payroll_settings_page.dart';
import '../features/master_data/presentation/settings_page.dart';
import '../features/portfolio/presentation/portfolio_form_page.dart';
import '../features/portfolio/presentation/portfolio_list_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/summary/presentation/summary_page.dart';
import '../features/transactions/presentation/transaction_form_page.dart';
import '../features/transactions/presentation/transaction_list_page.dart';
import 'main_shell.dart';

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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const DashboardPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    builder: (context, state) =>
                        TransactionFormPage(transaction: state.extra as TransactionModel?),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/summary', builder: (context, state) => const SummaryPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    builder: (context, state) => PortfolioFormPage(portfolio: state.extra as PortfolioModel?),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(path: 'categories', builder: (context, state) => const CategoryListPage()),
                  GoRoute(path: 'investments', builder: (context, state) => const InvestmentListPage()),
                  GoRoute(path: 'payroll', builder: (context, state) => const PayrollSettingsPage()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
