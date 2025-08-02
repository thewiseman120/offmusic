import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A responsive widget that adapts its layout based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= AppTheme.tabletBreakpoint) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= AppTheme.mobileBreakpoint) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// A responsive builder that provides screen size information
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    ScreenType screenType,
  ) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        return builder(context, constraints, screenType);
      },
    );
  }

  ScreenType _getScreenType(double width) {
    if (width >= AppTheme.tabletBreakpoint) {
      return ScreenType.desktop;
    } else if (width >= AppTheme.mobileBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
}

enum ScreenType { mobile, tablet, desktop }

/// A responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        int columns;
        switch (screenType) {
          case ScreenType.mobile:
            columns = mobileColumns;
            break;
          case ScreenType.tablet:
            columns = tabletColumns;
            break;
          case ScreenType.desktop:
            columns = desktopColumns;
            break;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: childAspectRatio ?? 1.0,
          children: children,
        );
      },
    );
  }
}

/// A responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        EdgeInsets padding;
        switch (screenType) {
          case ScreenType.mobile:
            padding = mobile ?? const EdgeInsets.all(16.0);
            break;
          case ScreenType.tablet:
            padding = tablet ?? const EdgeInsets.all(24.0);
            break;
          case ScreenType.desktop:
            padding = desktop ?? const EdgeInsets.all(32.0);
            break;
        }

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// A responsive text widget that adapts font size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        double fontSize;
        switch (screenType) {
          case ScreenType.mobile:
            fontSize = mobileFontSize ?? 16.0;
            break;
          case ScreenType.tablet:
            fontSize = tabletFontSize ?? 18.0;
            break;
          case ScreenType.desktop:
            fontSize = desktopFontSize ?? 20.0;
            break;
        }

        return Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// A responsive sized box
class ResponsiveSizedBox extends StatelessWidget {
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, screenType) {
        double? height;
        double? width;

        switch (screenType) {
          case ScreenType.mobile:
            height = mobileHeight;
            width = mobileWidth;
            break;
          case ScreenType.tablet:
            height = tabletHeight ?? mobileHeight;
            width = tabletWidth ?? mobileWidth;
            break;
          case ScreenType.desktop:
            height = desktopHeight ?? tabletHeight ?? mobileHeight;
            width = desktopWidth ?? tabletWidth ?? mobileWidth;
            break;
        }

        return SizedBox(
          height: height,
          width: width,
          child: child,
        );
      },
    );
  }
}
