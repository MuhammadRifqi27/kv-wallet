import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/storage/biometric_preference_service.dart';
import 'core/storage/locale_preference_service.dart';
import 'core/storage/notification_preference_service.dart';
import 'core/storage/onboarding_service.dart';
import 'core/storage/theme_preference_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/tour/application/tour_controller.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-guess status bar style before the widget tree (and therefore
  // FlowrApp.build's real brightness resolution) exists yet — corrected on
  // the very first frame regardless, see FlowrApp.build.
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);

  // Read once up front so the router's redirect (which runs synchronously)
  // knows immediately whether to show onboarding, instead of adding a
  // separate "loading" state to wait on.
  final hasSeenOnboarding = await OnboardingService().hasSeenOnboarding();
  final biometricEnabled = await BiometricPreferenceService().isEnabled();
  final themeMode = await ThemePreferenceService().getThemeMode();
  final locale = await LocalePreferenceService().getLocale();
  final budgetNotificationsEnabled = await NotificationPreferenceService().isEnabled();

  runApp(
    ProviderScope(
      overrides: [
        hasSeenOnboardingProvider.overrideWith((ref) => hasSeenOnboarding),
        biometricEnabledProvider.overrideWith((ref) => biometricEnabled),
        themeModeProvider.overrideWith((ref) => themeMode),
        localeProvider.overrideWith((ref) => locale),
        budgetNotificationsEnabledProvider.overrideWith((ref) => budgetNotificationsEnabled),
      ],
      child: const FlowrApp(),
    ),
  );
}

class FlowrApp extends ConsumerWidget {
  const FlowrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    // Eagerly create TourController here (root of the tree) so its
    // `ShowcaseView.register()` call (see tour_controller.dart) always runs
    // before any descendant's `Showcase` widget builds — MainShell's nav
    // icons and DashboardPage's cards both need the registration to already
    // exist, and relying on which of those two happens to build first would
    // be fragile.
    ref.read(tourControllerProvider);

    // Consumes the route a tapped local notification asked for (see
    // pendingNotificationRouteProvider's doc) and resets it — a listener
    // instead of a build-time read since this must fire once per tap, not
    // once per rebuild.
    ref.listen<String?>(pendingNotificationRouteProvider, (previous, next) {
      if (next != null) {
        router.go(next);
        ref.read(pendingNotificationRouteProvider.notifier).state = null;
      }
    });

    // AppColors is a static namespace read directly by ~45 files instead of
    // through `Theme.of(context)` (see AppColors' class doc for why) — this
    // is the one place that resolves the user's ThemeMode + the platform's
    // own brightness into the single flag every one of those reads.
    final platformIsDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = switch (themeMode) {
      ThemeMode.system => platformIsDark,
      ThemeMode.light => false,
      ThemeMode.dark => true,
    };
    AppColors.updateBrightness(isDark);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);

    return MaterialApp.router(
      title: 'Flowr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
