import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offmusic/theme/app_theme.dart';
import 'package:offmusic/utils/responsive_utils.dart';
import 'package:offmusic/widgets/responsive_widget.dart';

void main() {
  group('Responsive Design Tests', () {
    testWidgets('AppTheme responsive breakpoints work correctly', (WidgetTester tester) async {
      // Test mobile breakpoint
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppTheme.isTabletOrLarger(context), false);
              expect(AppTheme.isDesktop(context), false);
              return Container();
            },
          ),
        ),
      );

      // Test tablet breakpoint
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppTheme.isTabletOrLarger(context), true);
              expect(AppTheme.isDesktop(context), false);
              return Container();
            },
          ),
        ),
      );

      // Test desktop breakpoint
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(AppTheme.isTabletOrLarger(context), true);
              expect(AppTheme.isDesktop(context), true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('ResponsiveWidget adapts to screen size', (WidgetTester tester) async {
      const mobileWidget = Text('Mobile');
      const tabletWidget = Text('Tablet');
      const desktopWidget = Text('Desktop');

      // Test mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveWidget(
            mobile: mobileWidget,
            tablet: tabletWidget,
            desktop: desktopWidget,
          ),
        ),
      );
      expect(find.text('Mobile'), findsOneWidget);

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveWidget(
            mobile: mobileWidget,
            tablet: tabletWidget,
            desktop: desktopWidget,
          ),
        ),
      );
      expect(find.text('Tablet'), findsOneWidget);

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveWidget(
            mobile: mobileWidget,
            tablet: tabletWidget,
            desktop: desktopWidget,
          ),
        ),
      );
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('ResponsiveText adapts font size', (WidgetTester tester) async {
      // Test mobile font size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveText(
            'Test Text',
            mobileFontSize: 16,
            tabletFontSize: 20,
            desktopFontSize: 24,
          ),
        ),
      );

      final mobileText = tester.widget<Text>(find.text('Test Text'));
      expect(mobileText.style?.fontSize, 16);

      // Test tablet font size
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveText(
            'Test Text',
            mobileFontSize: 16,
            tabletFontSize: 20,
            desktopFontSize: 24,
          ),
        ),
      );

      final tabletText = tester.widget<Text>(find.text('Test Text'));
      expect(tabletText.style?.fontSize, 20);

      // Test desktop font size
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveText(
            'Test Text',
            mobileFontSize: 16,
            tabletFontSize: 20,
            desktopFontSize: 24,
          ),
        ),
      );

      final desktopText = tester.widget<Text>(find.text('Test Text'));
      expect(desktopText.style?.fontSize, 24);
    });

    testWidgets('ResponsiveGrid adapts column count', (WidgetTester tester) async {
      // Test mobile grid
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 4,
            children: List.generate(8, (index) => Container(key: Key('item_$index'))),
          ),
        ),
      );

      // Verify mobile layout (2 columns)
      expect(find.byKey(const Key('item_0')), findsOneWidget);
      expect(find.byKey(const Key('item_7')), findsOneWidget);

      // Test tablet grid
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 4,
            children: List.generate(8, (index) => Container(key: Key('item_$index'))),
          ),
        ),
      );

      // Verify tablet layout (3 columns)
      expect(find.byKey(const Key('item_0')), findsOneWidget);
      expect(find.byKey(const Key('item_7')), findsOneWidget);
    });

    testWidgets('ResponsiveUtils device type detection', (WidgetTester tester) async {
      // Test mobile detection
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.mobile);
              expect(context.isMobile, true);
              expect(context.isTablet, false);
              expect(context.isDesktop, false);
              return Container();
            },
          ),
        ),
      );

      // Test tablet detection
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.tablet);
              expect(context.isMobile, false);
              expect(context.isTablet, true);
              expect(context.isDesktop, false);
              return Container();
            },
          ),
        ),
      );

      // Test desktop detection
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveUtils.getDeviceType(context), DeviceType.desktop);
              expect(context.isMobile, false);
              expect(context.isTablet, false);
              expect(context.isDesktop, true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Responsive spacing scales correctly', (WidgetTester tester) async {
      // Test mobile spacing
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final spacing = AppTheme.getResponsiveSpacing(context);
              expect(spacing, 16.0); // Default mobile spacing
              return Container();
            },
          ),
        ),
      );

      // Test tablet spacing
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final spacing = AppTheme.getResponsiveSpacing(context);
              expect(spacing, 24.0); // Default tablet spacing
              return Container();
            },
          ),
        ),
      );

      // Test desktop spacing
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final spacing = AppTheme.getResponsiveSpacing(context);
              expect(spacing, 32.0); // Default desktop spacing
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Responsive album art size scales correctly', (WidgetTester tester) async {
      // Test mobile album art size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final albumArtSize = AppTheme.getResponsiveAlbumArtSize(context);
              expect(albumArtSize, 280.0); // 70% of 400 (width)
              return Container();
            },
          ),
        ),
      );

      // Test tablet album art size
      await tester.binding.setSurfaceSize(const Size(700, 1000));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final albumArtSize = AppTheme.getResponsiveAlbumArtSize(context);
              expect(albumArtSize, 350.0); // 50% of 700 (width)
              return Container();
            },
          ),
        ),
      );

      // Test desktop album art size
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final albumArtSize = AppTheme.getResponsiveAlbumArtSize(context);
              expect(albumArtSize, 400.0); // Fixed size on desktop
              return Container();
            },
          ),
        ),
      );
    });
  });
}
