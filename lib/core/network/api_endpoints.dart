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

  /// Not live on the backend yet — self-registration is still admin-only
  /// (see docs/flutter-mobile-app-development-guide.txt BAGIAN 2 & 7).
  static const String register = '/auth/register';

  static const String categories = '/money-management/categories';
  static const String investments = '/money-management/investments';
  static const String settings = '/money-management/settings';
  static const String portfolios = '/money-management/portfolios';
  static const String dashboard = '/money-management/dashboard';
  static const String summary = '/money-management/summary';
  static const String transactions = '/money-management/transactions';
}
