import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/btc_tracking_model.dart';
import '../data/models/budget_model.dart';
import '../data/models/portfolio_model.dart';
import '../data/models/recurring_transaction_model.dart';
import '../data/models/savings_goal_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transfer_model.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/password_reset_status_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/budget/presentation/budget_form_page.dart';
import '../features/budget/presentation/budget_list_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/investment/presentation/asset_detail_page.dart';
import '../features/investment/presentation/btc_activity_page.dart';
import '../features/investment/presentation/btc_entry_form_page.dart';
import '../features/investment/presentation/investment_dashboard_page.dart';
import '../features/master_data/presentation/category_list_page.dart';
import '../features/master_data/presentation/investment_list_page.dart';
import '../features/master_data/presentation/payroll_settings_page.dart';
import '../core/providers/core_providers.dart';
import '../features/membership/presentation/membership_plans_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/pin/application/pin_controller.dart';
import '../features/pin/presentation/change_pin_page.dart';
import '../features/pin/presentation/set_pin_page.dart';
import '../features/pin/presentation/verify_pin_page.dart';
import '../features/profile/presentation/change_password_page.dart';
import '../features/profile/presentation/edit_profile_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/portfolio/presentation/portfolio_form_page.dart';
import '../features/portfolio/presentation/portfolio_list_page.dart';
import '../features/recurring/presentation/recurring_form_page.dart';
import '../features/recurring/presentation/recurring_list_page.dart';
import '../features/savings_goals/presentation/savings_goal_detail_page.dart';
import '../features/savings_goals/presentation/savings_goal_form_page.dart';
import '../features/savings_goals/presentation/savings_goal_list_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/summary/presentation/summary_page.dart';
import '../features/transactions/presentation/transaction_form_page.dart';
import '../features/transactions/presentation/transaction_list_page.dart';
import '../features/transfers/presentation/transfer_form_page.dart';
import '../features/transfers/presentation/transfer_list_page.dart';
import 'main_shell.dart';

/// Bridges Riverpod state changes into something [GoRouter]'s
/// `refreshListenable` understands, so login/logout/pin-verify re-triggers
/// redirects.
/// Mirrors the permission keys in routing/main_shell.dart's `_navItems` —
/// see docs/flutter-navbar-permission-gating-plan.txt BAGIAN 0.
/// Order matters — [_permissionFor] returns the first matching entry, so
/// `/portfolio/transfers` and `/transactions/recurring` must be listed
/// before their more general parent (`/portfolio`, `/transactions`) or
/// they'd incorrectly inherit that parent's permission instead of their
/// own (`internal-transfers`, `recurring`).
const _routePermissions = {
  '/home': 'dashboard',
  '/transactions/recurring': 'recurring',
  '/transactions': 'transactions',
  '/summary': 'summary',
  '/portfolio/transfers': 'internal-transfers',
  '/portfolio': 'portfolio',
  '/savings-goals': 'savings-goals',
  '/budget': 'budgets',
  '/investment': 'btc-tracking',
  '/profile': 'settings',
};

/// [_routePermissions] lookup that also covers nested routes under each
/// branch (e.g. `/portfolio/form`, `/profile/categories`).
String? _permissionFor(String location) {
  for (final entry in _routePermissions.entries) {
    if (location == entry.key || location.startsWith('${entry.key}/')) {
      return entry.value;
    }
  }
  return null;
}

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(pinVerifiedProvider, (_, _) => notifyListeners());
    ref.listen(hasSeenOnboardingProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefresh(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (!ref.read(hasSeenOnboardingProvider)) {
        return onOnboarding ? null : '/onboarding';
      }
      if (onOnboarding) {
        // Flag flipped (slides just finished) while still sitting on this
        // route — move on to the normal auth-driven flow.
        return '/splash';
      }

      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final onAuthPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      // Admin-mediated reset ticket + tracking (docs/password-reset-request-flow.md)
      // — reachable pre-login, same as /login and /register. Actually setting
      // the new password happens on the web link the admin sends via
      // WhatsApp/telepon, outside the app.
      final onPasswordResetFlow =
          state.matchedLocation == '/forgot-password' || state.matchedLocation == '/forgot-password/status';
      final onSplash = state.matchedLocation == '/splash';
      final onPinSet = state.matchedLocation == '/pin/set';
      final onPinVerify = state.matchedLocation == '/pin/verify';

      switch (status) {
        case AuthStatus.unknown:
          return onSplash ? null : '/splash';
        case AuthStatus.authenticating:
          // Transient loading state while login/register is in flight —
          // stay put so the current page can show its own spinner instead
          // of bouncing through Splash mid-request.
          return null;
        case AuthStatus.authenticated:
          // PIN app-lock gate — every authenticated session must pass
          // through /pin/set (no PIN yet) or /pin/verify (has one, not
          // unlocked this session) before reaching the rest of the app.
          final hasPin = authState.user?.hasPin ?? false;
          if (!hasPin) {
            return onPinSet ? null : '/pin/set';
          }
          if (!ref.read(pinVerifiedProvider)) {
            return onPinVerify ? null : '/pin/verify';
          }
          if (onAuthPage || onSplash || onPinSet || onPinVerify || onPasswordResetFlow) {
            return '/home';
          }
          // Defense-in-depth: MainShell already stops locked tabs from
          // being tapped (see routing/main_shell.dart), this just catches
          // anyone who lands on a locked route another way (deep link,
          // stale navigation state after a plan downgrade, etc).
          final requiredPermission = _permissionFor(state.matchedLocation);
          if (requiredPermission != null && !(authState.user?.hasPermission(requiredPermission) ?? false)) {
            return '/profile/membership';
          }
          return null;
        case AuthStatus.unauthenticated:
          return (onAuthPage || onPasswordResetFlow) ? null : '/login';
      }
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(
        path: '/forgot-password/status',
        builder: (context, state) => PasswordResetStatusPage(initialIdentifier: state.extra as String?),
      ),
      GoRoute(path: '/pin/set', builder: (context, state) => const SetPinPage()),
      GoRoute(path: '/pin/verify', builder: (context, state) => const VerifyPinPage()),
      // Portfolio lives outside the bottom-nav shell — it's reached via a
      // menu tile on the Profile page (ProfilePage), pushed as a regular
      // full-screen route instead of an IndexedStack branch.
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioListPage(),
        routes: [
          GoRoute(
            path: 'form',
            builder: (context, state) => PortfolioFormPage(portfolio: state.extra as PortfolioModel?),
          ),
          GoRoute(
            path: 'transfers',
            builder: (context, state) => const TransferListPage(),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) => TransferFormPage(transfer: state.extra as TransferModel?),
              ),
            ],
          ),
        ],
      ),
      // Also off the bottom-nav shell, same precedent as Portfolio above —
      // reached via a menu tile on the Profile page (and a summary card on
      // the Dashboard).
      GoRoute(
        path: '/savings-goals',
        builder: (context, state) => const SavingsGoalListPage(),
        routes: [
          GoRoute(
            path: 'form',
            builder: (context, state) => SavingsGoalFormPage(goal: state.extra as SavingsGoalModel?),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => SavingsGoalDetailPage(goal: state.extra as SavingsGoalModel),
          ),
        ],
      ),
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
                  GoRoute(
                    path: 'recurring',
                    builder: (context, state) => const RecurringListPage(),
                    routes: [
                      GoRoute(
                        path: 'form',
                        builder: (context, state) =>
                            RecurringFormPage(recurring: state.extra as RecurringTransactionModel?),
                      ),
                    ],
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
                path: '/budget',
                builder: (context, state) => const BudgetListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    builder: (context, state) => BudgetFormPage(budget: state.extra as BudgetCategoryItem?),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/investment',
                builder: (context, state) => const InvestmentDashboardPage(),
                routes: [
                  GoRoute(
                    path: 'entry-form',
                    builder: (context, state) => BtcEntryFormPage(entry: state.extra as BtcActivityItem?),
                  ),
                  GoRoute(path: 'activity', builder: (context, state) => const BtcActivityPage()),
                  GoRoute(
                    path: 'asset/:symbol',
                    builder: (context, state) => AssetDetailPage(asset: state.pathParameters['symbol']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(path: 'edit', builder: (context, state) => const EditProfilePage()),
                  GoRoute(path: 'change-password', builder: (context, state) => const ChangePasswordPage()),
                  GoRoute(path: 'change-pin', builder: (context, state) => const ChangePinPage()),
                  GoRoute(path: 'categories', builder: (context, state) => const CategoryListPage()),
                  GoRoute(path: 'investments', builder: (context, state) => const InvestmentListPage()),
                  GoRoute(path: 'payroll', builder: (context, state) => const PayrollSettingsPage()),
                  GoRoute(path: 'membership', builder: (context, state) => const MembershipPlansPage()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
