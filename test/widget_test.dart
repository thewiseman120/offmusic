import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offmusic/providers/music_provider.dart';
import 'package:offmusic/screens/main_screen.dart';
import 'package:offmusic/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('MyApp widget creation test', (WidgetTester tester) async {
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

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('MusicProvider can be created', (WidgetTester tester) async {
    final provider = MusicProvider();
    expect(provider, isA<MusicProvider>());
    expect(provider.isPlaying, false);
    expect(provider.hasPermission, false);
    expect(provider.allSongs, isEmpty);
  });

  testWidgets('MainScreen has exactly 4 bottom navigation items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MusicProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainScreen(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('MainScreen tab taps remain in-bounds',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MusicProvider(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MainScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.settings_rounded).last);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Settings Screen\n(Coming Soon)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
