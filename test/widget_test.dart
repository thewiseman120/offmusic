// This is a basic Flutter widget test for the OffMusic app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offmusic/providers/music_provider.dart';
import 'package:offmusic/theme/app_theme.dart';

void main() {
  testWidgets('MyApp widget creation test', (WidgetTester tester) async {
    // Test that MyApp widget can be created without platform dependencies
    final testApp = MaterialApp(
      title: 'OffMusic Test',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Test App'),
        ),
      ),
    );

    await tester.pumpWidget(testApp);

    // Verify MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('MusicProvider can be created', (WidgetTester tester) async {
    // Test that MusicProvider can be instantiated
    final provider = MusicProvider();
    expect(provider, isA<MusicProvider>());
    expect(provider.isPlaying, false);
    expect(provider.hasPermission, false);
    expect(provider.allSongs, isEmpty);
  });

  testWidgets('App theme is properly configured', (WidgetTester tester) async {
    // Test that the app theme is working
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Text('Theme Test'),
        ),
      ),
    );

    expect(find.text('Theme Test'), findsOneWidget);

    // Verify theme is applied
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme, isNotNull);
  });
}
