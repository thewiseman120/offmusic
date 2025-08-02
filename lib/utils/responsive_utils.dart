import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Utility class for responsive design helpers
class ResponsiveUtils {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppTheme.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < AppTheme.tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get responsive value based on device type
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return EdgeInsets.all(
      AppTheme.getResponsiveSpacing(context, mobile: 8, tablet: 12, desktop: 16),
    );
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context) {
    final radius = AppTheme.getResponsiveSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    return BorderRadius.circular(radius);
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context) {
    return AppTheme.getResponsiveSpacing(context, mobile: 4, tablet: 6, desktop: 8);
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {
    double mobile = 24,
    double tablet = 28,
    double desktop = 32,
  }) {
    return AppTheme.getResponsiveFontSize(context, 
      mobile: mobile, 
      tablet: tablet, 
      desktop: desktop,
    );
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    return AppTheme.getResponsiveSpacing(context, mobile: 48, tablet: 56, desktop: 64);
  }

  /// Get responsive list tile height
  static double getResponsiveListTileHeight(BuildContext context) {
    return AppTheme.getResponsiveSpacing(context, mobile: 72, tablet: 80, desktop: 88);
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    return AppTheme.getResponsiveSpacing(context, mobile: 56, tablet: 64, desktop: 72);
  }

  /// Get responsive bottom navigation bar height
  static double getResponsiveBottomNavHeight(BuildContext context) {
    return AppTheme.getResponsiveSpacing(context, mobile: 60, tablet: 70, desktop: 80);
  }

  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final padding = AppTheme.getResponsiveSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    return EdgeInsets.all(padding);
  }

  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.9;
      case DeviceType.tablet:
        return screenWidth * 0.7;
      case DeviceType.desktop:
        return screenWidth * 0.5;
    }
  }

  /// Get responsive grid cross axis count
  static int getResponsiveGridCount(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    return AppTheme.getResponsiveGridCount(context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive text scale factor
  static double getResponsiveTextScale(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        return 1.2;
    }
  }

  /// Check if device supports hover interactions
  static bool supportsHover(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.windows ||
           Theme.of(context).platform == TargetPlatform.macOS ||
           Theme.of(context).platform == TargetPlatform.linux;
  }

  /// Get responsive animation duration
  static Duration getResponsiveAnimationDuration(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const Duration(milliseconds: 200);
      case DeviceType.tablet:
        return const Duration(milliseconds: 250);
      case DeviceType.desktop:
        return const Duration(milliseconds: 300);
    }
  }

  /// Get responsive shadow
  static List<BoxShadow> getResponsiveShadow(BuildContext context) {
    final elevation = getResponsiveElevation(context);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  /// Get responsive max width for content
  static double getResponsiveMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// Get responsive column count for layout
  static int getResponsiveColumnCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 1;
    if (screenWidth < 900) return 2;
    if (screenWidth < 1200) return 3;
    return 4;
  }

  /// Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context, {
    double mobile = 1.0,
    double tablet = 1.2,
    double desktop = 1.5,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

enum DeviceType { mobile, tablet, desktop }

/// Extension on BuildContext for easier responsive access
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.getDeviceType(this) == DeviceType.mobile;
  bool get isTablet => ResponsiveUtils.getDeviceType(this) == DeviceType.tablet;
  bool get isDesktop => ResponsiveUtils.getDeviceType(this) == DeviceType.desktop;
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);
  Size get screenSize => ResponsiveUtils.getScreenSize(this);
  double get screenWidth => ResponsiveUtils.getScreenSize(this).width;
  double get screenHeight => ResponsiveUtils.getScreenSize(this).height;
}
