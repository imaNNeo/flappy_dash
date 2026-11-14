import 'dart:ui';

import 'package:flappy_dash/domain/entities/dash_type.dart';

/// The colors of one dash skin. Every skin is the same drawing
/// ([DashPainter]) with a different palette.
class DashPalette {
  const DashPalette({
    required this.body,
    required this.shade,
    required this.eyeWhite,
    required this.outline,
  });

  /// The main (lit) color of the body, tuft and wings.
  final Color body;

  /// The darker color for the belly and the lower side of the feathers.
  final Color shade;

  final Color eyeWhite;

  /// Outlines, pupils and brows.
  final Color outline;

  static const _white = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF04020F);

  static DashPalette of(DashType type) => switch (type) {
    DashType.flutterDash => const DashPalette(
      body: Color(0xFF2AC6FD),
      shade: Color(0xFF2186F9),
      eyeWhite: Color(0xFFFBFDEC),
      outline: Color(0xFF29155D),
    ),
    DashType.limeDash => const DashPalette(
      body: Color(0xFFD0FF6F),
      shade: Color(0xFF7EE32C),
      eyeWhite: _white,
      outline: _ink,
    ),
    DashType.peachyDash => const DashPalette(
      body: Color(0xFFFDBDB3),
      shade: Color(0xFFF99171),
      eyeWhite: Color(0xFFF7F4FD),
      outline: _ink,
    ),
    DashType.roseDash => const DashPalette(
      body: Color(0xFFFDABE3),
      shade: Color(0xFFF969A6),
      eyeWhite: Color(0xFFECF1FD),
      outline: _ink,
    ),
    DashType.sandDash => const DashPalette(
      body: Color(0xFFFDCA7B),
      shade: Color(0xFFEA9F00),
      eyeWhite: Color(0xFFFDECF8),
      outline: _ink,
    ),
    DashType.scarletDash => const DashPalette(
      body: Color(0xFFFF635A),
      shade: Color(0xFFFB3610),
      eyeWhite: _white,
      outline: _ink,
    ),
    DashType.skyDash => const DashPalette(
      body: Color(0xFFA3EAFF),
      shade: Color(0xFF7DBEF9),
      eyeWhite: Color(0xFFFDFDFD),
      outline: _ink,
    ),
    DashType.mintyDash => const DashPalette(
      body: Color(0xFF5EF9A5),
      shade: Color(0xFF42A770),
      eyeWhite: Color(0xFFFDFDFD),
      outline: _ink,
    ),
    DashType.sunnyDash => const DashPalette(
      body: Color(0xFFFFD700),
      shade: Color(0xFFC9A800),
      eyeWhite: Color(0xFFFDFDFD),
      outline: _ink,
    ),
    DashType.violetDash => const DashPalette(
      body: Color(0xFFBEA2FD),
      shade: Color(0xFF953FF9),
      eyeWhite: Color(0xFFECFDF3),
      outline: _ink,
    ),
  };
}
