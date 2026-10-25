import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintech_app/main.dart';

void main() {
  testWidgets('Fintech App smoke test loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FintechApp(),
      ),
    );
    await tester.pump();
    expect(find.text('NOVA'), findsOneWidget);

    // Advance past splash transition
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('NOVA'), findsOneWidget);
    expect(find.text('GLOBAL TRANSFERS'), findsOneWidget);
  });
}
