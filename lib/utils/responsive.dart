import 'package:flutter/material.dart';

/// Breakpoints (Tailwind-এর মতো)
class AppBreakpoints {
  AppBreakpoints._();
  static const double tablet  = 768;   // >= tablet
  static const double desktop = 1024;  // >= desktop
  static const double xl      = 1280;  // >= xl
}

/// BuildContext extensions
extension ResponsiveContext on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);
  double get width       => mq.size.width;
  double get height      => mq.size.height;

  bool get isMobile      => width < AppBreakpoints.tablet;
  bool get isTablet      => width >= AppBreakpoints.tablet && width < AppBreakpoints.desktop;
  bool get isDesktop     => width >= AppBreakpoints.desktop;
  bool get isXL          => width >= AppBreakpoints.xl;

  /// Page gutter/padding
  EdgeInsets get pagePadding {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    if (isTablet)  return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  }

  /// Login card max width (ডিভাইসভেদে)
  double get loginCardMaxWidth {
    if (isXL)      return 520;
    if (isDesktop) return 500;
    if (isTablet)  return 480;
    return 460;
  }

  /// Content max container (টু-কলাম লে-আউটের total bound)
  double get contentMaxWidth {
    if (isXL)      return 1100;
    if (isDesktop) return 1000;
    if (isTablet)  return 880;
    return 600;
  }

  /// Gap (vertical/horizontal spacing)
  double get gapL => isDesktop ? 28 : (isTablet ? 24 : 20);
  double get gapM => isDesktop ? 20 : (isTablet ? 18 : 16);
  double get gapS => isDesktop ? 14 : (isTablet ? 12 : 10);
}
