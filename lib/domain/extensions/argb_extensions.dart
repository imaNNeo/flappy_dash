import 'package:particular/particular.dart';

extension ArgbExtensions on ARGB {
  ARGB suppressColorBy(double percent) => ARGB(
        0,
        (r * percent).toInt(),
        (g * percent).toInt(),
        (b * percent).toInt(),
      );
}
