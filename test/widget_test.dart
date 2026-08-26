import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowr/core/providers/core_providers.dart';
import 'package:flowr/main.dart';

void main() {
  testWidgets('Splash screen shows the Flowr brand mark', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // Skip onboarding so the router lands on /splash, same as a
        // returning device — onboarding's own content isn't under test here.
        overrides: [hasSeenOnboardingProvider.overrideWith((ref) => true)],
        child: const FlowrApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Flowr'), findsOneWidget);
  });
}
