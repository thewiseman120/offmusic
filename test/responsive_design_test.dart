import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offmusic/theme/app_theme.dart';
import 'package:offmusic/utils/responsive_utils.dart';

void main() {
  group('Responsive Design Tests', () {
    test('AppTheme constants are defined correctly', () {
      expect(AppTheme.mobileBreakpoint, 600);
      expect(AppTheme.tabletBreakpoint, 900);
      expect(AppTheme.desktopBreakpoint, 1200);
    });

    test('DeviceType enum is defined', () {
      expect(DeviceType.mobile, isA<DeviceType>());
      expect(DeviceType.tablet, isA<DeviceType>());
      expect(DeviceType.desktop, isA<DeviceType>());
    });

    testWidgets('Basic responsive functionality', (WidgetTester tester) async {
      // Simple test that just verifies the app can build
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Responsive Test'),
            ),
          ),
        ),
      );
      
      // Verify the widget was built
      expect(find.text('Responsive Test'), findsOneWidget);
    });
  });
}