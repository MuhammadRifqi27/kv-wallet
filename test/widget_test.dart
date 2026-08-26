import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowr/main.dart';

void main() {
  testWidgets('Splash screen shows the Flowr brand mark', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlowrApp()));
    await tester.pump();

    expect(find.text('Flowr'), findsOneWidget);
  });
}
