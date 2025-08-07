import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:offmusic/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('OffMusic Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app launches without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Music playback integration test', (WidgetTester tester) async {
      // TODO: Implement comprehensive integration tests
      // Test full music playback workflow
      // Test playlist creation and management
      // Test search functionality

      // For now, just verify the app structure
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}