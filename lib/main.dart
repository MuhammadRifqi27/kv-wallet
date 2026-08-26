import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() {
  // Covers screens without an AppBar (Splash/Login/Register/PIN pages) —
  // AppTheme.light's appBarTheme handles the rest. See AppTheme.statusBarStyle.
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);
  runApp(const ProviderScope(child: FlowrApp()));
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
