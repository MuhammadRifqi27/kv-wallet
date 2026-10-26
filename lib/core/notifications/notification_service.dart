import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../l10n/app_localizations.dart';
import '../utils/formatters.dart';

const _budgetChannel = AndroidNotificationChannel(
  'budget_alerts',
  'Peringatan Budget',
  description: 'Notifikasi saat pengeluaran mendekati atau melebihi budget kategori.',
  importance: Importance.high,
);

/// Thin wrapper over flutter_local_notifications — everything here is
/// LOCAL (device-only), no server/FCM involved. See
/// docs/flutter-notifications-plan.txt for the broader notification plan
/// and why push notifications are a separate, larger effort.
class NotificationService {
  /// [onNotificationTapped] receives the tapped notification's `payload`
  /// (a route string, e.g. `/budget`) — kept as a plain callback instead of
  /// reaching into `appRouterProvider` directly, since that would create an
  /// import cycle (app_router.dart already imports core_providers.dart,
  /// which is where notificationServiceProvider lives). See
  /// docs/ide-improvement-fitur-existing.txt BAGIAN G #40.
  ///
  /// [onNotificationShown] fires right after a notification is actually
  /// displayed, so the caller can log it for the in-app history page (see
  /// BAGIAN G #43) — same "plain callback, not a direct provider reach-in"
  /// reasoning as [onNotificationTapped].
  NotificationService({this.onNotificationTapped, this.onNotificationShown});

  final void Function(String route)? onNotificationTapped;
  final void Function(String title, String body)? onNotificationShown;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Sets up the plugin, the notification channel, and requests the
  /// runtime permission (Android 13+/iOS) — deliberately lazy (called from
  /// the first actual notification instead of app start) so the OS
  /// permission prompt shows up at a moment that's actually relevant to
  /// the user, not on cold start.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    // Must be a white/transparent silhouette (drawable/ic_stat_notification,
    // copied from assets/branding/icon_foreground.png) — Android tints
    // whatever non-transparent pixels it finds, so a full-color launcher
    // icon here renders as a plain white blob in the status bar.
    const androidInit = AndroidInitializationSettings('ic_stat_notification');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_budgetChannel);
    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      onNotificationTapped?.call(payload);
    }
  }

  Future<void> showBudgetExceededNotification({
    required int categoryId,
    required String categoryName,
    required double spent,
    required double amount,
    required int month,
    required int year,
    required Locale locale,
  }) async {
    await _ensureInitialized();
    // No BuildContext here (fired from a controller, not a widget build) —
    // load the strings for the caller-resolved locale directly instead of
    // `AppLocalizations.of(context)`. See [effectiveLocaleProvider]'s doc.
    final l10n = await AppLocalizations.delegate.load(locale);
    final title = l10n.notificationBudgetExceededTitle(categoryName);
    final body = l10n.notificationBudgetExceededBody(formatRupiah(spent), formatRupiah(amount), monthName(month, locale), year);
    await _plugin.show(
      id: categoryId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Peringatan Budget',
          channelDescription: 'Notifikasi saat pengeluaran mendekati atau melebihi budget kategori.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: '/budget',
    );
    onNotificationShown?.call(title, body);
  }

  /// Early warning shown once a category crosses [BudgetCategoryItem.
  /// isNearLimit] (>=80% used, not yet over) — reuses the same
  /// notification `id` as [showBudgetExceededNotification] for the same
  /// category so a later "over budget" alert naturally supersedes an
  /// earlier "near limit" one in the OS tray instead of stacking both.
  Future<void> showBudgetNearLimitNotification({
    required int categoryId,
    required String categoryName,
    required double spent,
    required double amount,
    required int month,
    required int year,
    required Locale locale,
  }) async {
    await _ensureInitialized();
    final l10n = await AppLocalizations.delegate.load(locale);
    final title = l10n.notificationBudgetNearLimitTitle(categoryName);
    final body = l10n.notificationBudgetNearLimitBody(formatRupiah(spent), formatRupiah(amount), monthName(month, locale), year);
    await _plugin.show(
      id: categoryId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Peringatan Budget',
          channelDescription: 'Notifikasi saat pengeluaran mendekati atau melebihi budget kategori.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: '/budget',
    );
    onNotificationShown?.call(title, body);
  }
}
