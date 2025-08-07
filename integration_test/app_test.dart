import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offmusic/main.dart' as app;

void main() {
  // Use the integration test binding so platform plugins are available.
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // For stability, allow unrestricted frame policy (optional).
  // binding.deferFirstFrame();

  group('OffMusic Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Launch app via main(); integration binding sets up plugins.
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify MaterialApp exists
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Basic structure renders', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Expect to see something from splash or subsequent screen
      // Splash shows progress indicator and app title
      expect(find.text('OffMusic'), findsAtLeastNWidgets(1));
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
