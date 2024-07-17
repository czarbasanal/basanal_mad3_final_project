import 'package:flutter/material.dart';

class Constants {
  static Color primaryColor = const Color(0xFF006491);
  static Color textColorLightTheme = const Color(0xFF0D0D0E);

  static Color secondaryColor80LightTheme = const Color(0xFF202225);
  static Color secondaryColor60LightTheme = const Color(0xFF313336);
  static Color secondaryColor40LightTheme = const Color(0xFF585858);
  static Color secondaryColor20LightTheme = const Color(0xFF787F84);
  static Color secondaryColor10LightTheme = const Color(0xFFEEEEEE);
  static Color secondaryColor5LightTheme = const Color(0xFFF8F8F8);

  static const defaultPadding = 16.0;
}

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  static double textMultiplier = 0;
  static double imageSizeMultiplier = 0;
  static double heightMultiplier = 0;

  static bool isPortrait = true;
  static bool isMobilePortrait = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    textMultiplier = blockSizeVertical;
    imageSizeMultiplier = blockSizeHorizontal;
    heightMultiplier = blockSizeVertical;

    isPortrait = _mediaQueryData!.orientation == Orientation.portrait;
    isMobilePortrait = isPortrait && screenWidth < 450;
  }
}
