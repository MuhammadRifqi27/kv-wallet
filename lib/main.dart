import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/storage/biometric_preference_service.dart';
import 'core/storage/onboarding_service.dart';
import 'core/storage/theme_preference_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        hasSeenOnboardingProvider.overrideWith((ref) => hasSeenOnboarding),
        biometricEnabledProvider.overrideWith((ref) => biometricEnabled),
        themeModeProvider.overrideWith((ref) => themeMode),
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
    );
  }
}
