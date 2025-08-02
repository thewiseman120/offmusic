import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF8B5FBF);
  static const Color lightBlue = Color(0xFFB8E6FF);
  static const Color pastelLavender = Color(0xFFE6E6FA);
  static const Color softWhite = Color(0xFFFAFAFA);

  static final LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      pastelLavender,
      lightBlue.withValues(alpha: 0.7),
      softWhite,
    ],
    stops: const [0.0, 0.5, 1.0],
  );

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return mobile;
    if (width < tabletBreakpoint) return tablet;
    return desktop;
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, {
    double mobile = 16.0,
    double tablet = 18.0,
    double desktop = 20.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return mobile;
    if (width < tabletBreakpoint) return tablet;
    return desktop;
  }

  // Get responsive grid count
  static int getResponsiveGridCount(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return mobile;
    if (width < tabletBreakpoint) return tablet;
    return desktop;
  }

  // Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint;
  }

  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive card size
  static double getResponsiveCardSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 120.0;
    if (width < tabletBreakpoint) return 140.0;
    return 160.0;
  }

  // Get responsive album art size
  static double getResponsiveAlbumArtSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final minDimension = width < height ? width : height;

    if (width < mobileBreakpoint) {
      return minDimension * 0.7; // 70% of smaller dimension on mobile
    } else if (width < tabletBreakpoint) {
      return minDimension * 0.5; // 50% of smaller dimension on tablet
    } else {
      return 400.0; // Fixed size on desktop
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      selectedItemColor: primaryPurple,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.8),
      elevation: 8,
      shadowColor: primaryPurple.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}