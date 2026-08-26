import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/storage/onboarding_service.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Covers screens without an AppBar (Splash/Login/Register/PIN pages) —
  // AppTheme.light's appBarTheme handles the rest. See AppTheme.statusBarStyle.
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);

  // Read once up front so the router's redirect (which runs synchronously)
  // knows immediately whether to show onboarding, instead of adding a
  // separate "loading" state to wait on.
  final hasSeenOnboarding = await OnboardingService().hasSeenOnboarding();

  runApp(
    ProviderScope(
      overrides: [hasSeenOnboardingProvider.overrideWith((ref) => hasSeenOnboarding)],
      child: const FlowrApp(),
    ),
  );
}

class FlowrApp extends ConsumerWidget {
  const FlowrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Flowr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
