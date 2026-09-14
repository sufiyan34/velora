import 'package:flutter/widgets.dart';

/// Breakpoints shared by the products and categories admin screens.
///
/// - mobile: stacked cards, full-screen forms
/// - tablet: table view, forms as a centered dialog/drawer
/// - desktop: table view, wider drawer, side-by-side filters
class Responsive {
  Responsive._();

  static const double mobileMax = 760;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileMax && w < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;
}
