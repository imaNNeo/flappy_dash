import 'package:flutter/material.dart';

const _extraSmallScreen = 400.0;
const _smallScreen = 600.0;
const _mediumScreen = 1024.0;
const _largeScreen = 1440.0;

enum ScreenSize {
  extraSmall,
  small,
  medium,
  large,
  extraLarge;

  double get breakpoint => switch (this) {
        ScreenSize.extraSmall => _extraSmallScreen,
        ScreenSize.small => _smallScreen,
        ScreenSize.medium => _mediumScreen,
        ScreenSize.large => _largeScreen,
        ScreenSize.extraLarge => double.infinity,
      };

  factory ScreenSize.fromContext(BuildContext context) =>
      ScreenSize.fromWidth(MediaQuery.of(context).size.width);

  factory ScreenSize.fromWidth(double width) {
    if (width < _extraSmallScreen) {
      return ScreenSize.extraSmall;
    } else if (width < _smallScreen) {
      return ScreenSize.small;
    } else if (width < _mediumScreen) {
      return ScreenSize.medium;
    } else if (width < _largeScreen) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }
}
