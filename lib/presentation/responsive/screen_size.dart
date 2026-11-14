import 'package:flutter/material.dart';

const _extraSmallScreen = 400.0;
const _smallScreen = 600.0;
const _mediumScreen = 1024.0;
const _largeScreen = 1440.0;

// Height breakpoints. A wide but short window (a phone in landscape, a
// laptop browser with toolbars) must not get desktop-sized UI, otherwise the
// content runs off the bottom of the screen.
const _extraSmallHeight = 480.0;
const _smallHeight = 640.0;
const _mediumHeight = 820.0;
const _largeHeight = 1100.0;

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

  /// The size class of the screen, taking the smaller of the width class and
  /// the height class, so the UI scales down on short screens too.
  factory ScreenSize.fromContext(BuildContext context) =>
      ScreenSize.fromSize(MediaQuery.sizeOf(context));

  factory ScreenSize.fromSize(Size size) {
    final byWidth = ScreenSize.fromWidth(size.width);
    final byHeight = ScreenSize.fromHeight(size.height);
    return byWidth.index <= byHeight.index ? byWidth : byHeight;
  }

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

  factory ScreenSize.fromHeight(double height) {
    if (height < _extraSmallHeight) {
      return ScreenSize.extraSmall;
    } else if (height < _smallHeight) {
      return ScreenSize.small;
    } else if (height < _mediumHeight) {
      return ScreenSize.medium;
    } else if (height < _largeHeight) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }
}

extension ResponsiveContext on BuildContext {
  /// True for screens that are clearly wider than tall and short, like a
  /// phone in landscape or a small laptop window. Pages switch to a
  /// side-by-side layout there instead of stacking everything vertically.
  bool get isShortLandscape {
    final size = MediaQuery.sizeOf(this);
    return size.width > size.height * 1.25 && size.height < 720;
  }
}
