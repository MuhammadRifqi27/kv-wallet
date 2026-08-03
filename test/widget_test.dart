import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kv_wallet/main.dart';

void main() {
  testWidgets('Splash screen shows the KVWallet brand mark', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KVWalletApp()));
    await tester.pump();

    expect(find.text('KVWallet'), findsOneWidget);
  });
}
