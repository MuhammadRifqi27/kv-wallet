/// Base URL for a locally-run `php artisan serve`.
/// - Android emulator: `http://10.0.2.2:8000/api/v1`
/// - Physical device (same Wi-Fi as your PC): `http://<PC LAN IP>:8000/api/v1`
///   (127.0.0.1 on a physical phone means the phone itself, not your PC —
///   also start Laravel with `php artisan serve --host=0.0.0.0` so it
///   accepts connections from other devices on the network)
/// - Chrome/Windows desktop on this same machine: `http://127.0.0.1:8000/api/v1`
/// Swap to the production domain once deployed (see
/// docs/flutter-mobile-app-development-guide.txt).
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://kodevisual.com/api/v1';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String register = '/auth/register';

  /// Admin-mediated password reset — no email/SMS provider, see
  /// docs/password-reset-request-flow.md. Both are public (no bearer token
  /// needed, user isn't logged in at this point). Setting the new password
  /// itself happens on the web `reset-password` page the admin sends via
  /// WhatsApp/telepon, not through this API — the app only tracks the ticket.
  static const String passwordResetRequest = '/auth/password-reset-request';
  static const String passwordResetRequestStatus = '/auth/password-reset-request/status';

  /// Partial update (name/username/email/avatar) — see docs/mobile-api-reference.md.
  static const String profile = '/auth/profile';

  /// For a user who's still logged in and knows their current password —
  /// not the admin-mediated "forgot password" flow above.
  static const String changePassword = '/auth/change-password';

  /// Set/change PIN (`current_pin` required only when changing an existing
  /// one) — see docs/pin-and-membership-plan-api-reference.md.
  static const String pin = '/auth/pin';
  static const String verifyPin = '/auth/verify-pin';

  static const String membershipPlans = '/membership/plans';
  static const String membershipSelectPlan = '/membership/select-plan';
  static const String membershipStatus = '/membership/status';

  static const String budgets = '/money-management/budgets';
  static const String categories = '/money-management/categories';
  static const String investments = '/money-management/investments';
  static const String settings = '/money-management/settings';
  static const String portfolios = '/money-management/portfolios';
  static const String dashboard = '/money-management/dashboard';
  static const String summary = '/money-management/summary';
  static const String transactions = '/money-management/transactions';

  /// `GET` here has a side effect — it processes any due recurring template
  /// into a real transaction before returning the list (see
  /// docs/flutter-mobile-app-development-guide.txt "RECURRING otomatis
  /// diproses..."). `/process` is for triggering that same processing from
  /// a screen that doesn't otherwise call the list endpoint (Dashboard).
  static const String recurring = '/money-management/recurring';
  static const String recurringProcess = '/money-management/recurring/process';

  static const String btcTracking = '/money-management/btc-tracking';
  static const String btcTrackingActivity = '/money-management/btc-tracking/activity';

  static const String savingsGoals = '/money-management/savings-goals';

  /// See TransferModel's schema-verification note — request body confirmed
  /// against docs/flutter-mobile-app-development-guide.txt, response shape
  /// unverified.
  static const String transfers = '/money-management/transfers';
}
