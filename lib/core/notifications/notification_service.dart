import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_budgetChannel);
    await androidPlugin?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showBudgetExceededNotification({
    required int categoryId,
    required String categoryName,
    required double spent,
    required double amount,
    required int month,
    required int year,
  }) async {
    await _ensureInitialized();
    await _plugin.show(
      id: categoryId,
      title: 'Budget $categoryName Terlampaui',
      body: 'Terpakai ${formatRupiah(spent)} dari budget ${formatRupiah(amount)} bulan ${monthName(month)} $year.',
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
    );
  }
}
