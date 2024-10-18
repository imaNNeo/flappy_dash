import 'dart:ui';

import 'package:particular/particular.dart';

extension ColorExtension on Color {
  /// Convert a color to a hex string
  ARGB toARGB() => ARGB(
        alpha / 255,
        red / 255,
        green / 255,
        blue / 255,
      );
}
