import 'package:flutter/material.dart';

class Responsive {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double setWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * (percentage / 100);
  }

  static double setHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * (percentage / 100);
  }

  static double fontSize(BuildContext context, double size) {
    final scale = getScreenWidth(context) / 375.0; // Base reference width: 375
    return size * (scale.clamp(0.85, 1.25));
  }

  static double padding(BuildContext context, double size) {
    final scale = getScreenWidth(context) / 375.0;
    return size * (scale.clamp(0.85, 1.25));
  }

  static bool isMobile(BuildContext context) => getScreenWidth(context) < 600;
  static bool isTablet(BuildContext context) =>
      getScreenWidth(context) >= 600 && getScreenWidth(context) < 1024;
  static bool isDesktop(BuildContext context) => getScreenWidth(context) >= 1024;
}

extension ResponsiveExtension on BuildContext {
  double get screenWidth => Responsive.getScreenWidth(this);
  double get screenHeight => Responsive.getScreenHeight(this);
  double widthPct(double pct) => Responsive.setWidth(this, pct);
  double heightPct(double pct) => Responsive.setHeight(this, pct);
  double fontSp(double size) => Responsive.fontSize(this, size);
  double pad(double size) => Responsive.padding(this, size);
}
