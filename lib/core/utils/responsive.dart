import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int getCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static double getContentWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width > 1200) return 1200;
    if (width > 600) return width * 0.9;
    return width * 0.92;
  }

  static EdgeInsets getSectionPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 80, vertical: 60);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 40);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 30);
  }
}
