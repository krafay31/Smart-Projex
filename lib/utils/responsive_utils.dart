// responsive_utils.dart
import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
  
  static bool isMobile(BuildContext context) => 
      getScreenSize(context) == ScreenSize.mobile;
  
  static bool isTablet(BuildContext context) => 
      getScreenSize(context) == ScreenSize.tablet;
  
  static bool isDesktop(BuildContext context) => 
      getScreenSize(context) == ScreenSize.desktop;
  
  static double getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 32;
    }
  }
  
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800;
      case ScreenSize.desktop:
        return 1400;
    }
  }
  
  static int getGridCrossAxisCount(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 3;
      case ScreenSize.tablet:
        return 5;
      case ScreenSize.desktop:
        return 7;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;
  
  const ResponsiveBuilder({super.key, required this.builder});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(context);
        return builder(context, screenSize);
      },
    );
  }
}