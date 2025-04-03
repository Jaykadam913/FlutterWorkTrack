import 'package:flutter/widgets.dart';

class ScreenUtil {
  static late MediaQueryData _mediaQueryData;

  /// Initialize media query data (Call this in main)
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }

  static double get screenWidth => _mediaQueryData.size.width;
  static double get screenHeight => _mediaQueryData.size.height;
}

extension SizeExtension on num {
  /// Get responsive width (percentage of screen width)
  double get w => (this / 100) * ScreenUtil.screenWidth;

  /// Get responsive height (percentage of screen height)
  double get h => (this / 100) * ScreenUtil.screenHeight;

  /// Get responsive font size (percentage of screen width)
  double get sp => (this / 100) * ScreenUtil.screenWidth;
}
