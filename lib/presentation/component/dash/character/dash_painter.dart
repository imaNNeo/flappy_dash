import 'dart:ui';

import 'dash_face.dart';
import 'dash_palette.dart';

part 'dash_shape.g.dart';

/// Draws a dash (the bird) with code: no image assets. The drawing looks
/// right (beak to the right) and fills a [canvasSize] x [canvasSize] square,
/// which [paint] scales to any size.
///
/// The body, wings and beak are the original artwork's outlines (see
/// dash_shape.g.dart) recolored with a [DashPalette]. The parts that move
/// (eyes, pupils, lids, brows, cheeks, the front wing) come from a
/// [DashFace], so the same drawing can blink, smile, get scared, etc.
class DashPainter {
  DashPainter._();

  /// The size of the drawing in its own units.
  static const double canvasSize = 138;

  /// How far down (radians) the front wing can swing.
  static const double maxWingSwing = 0.22;

  static const _beakColor = Color(0xFFFABC01);
  static const _beakShadeColor = Color(0xFFFF560F);
  static const _blush = Color(0xFFFF5C8A);
  static const _sweat = Color(0xFF9EE6FF);

  static final _fill = Paint()..isAntiAlias = true;
  static final _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final List<_ShapeLayer> _layers = [
    for (final (layer, data) in _dashLayers)
      if (layer != _Layer.nearEye && layer != _Layer.farEye)
        _ShapeLayer(layer, _parseSvgPath(data)),
  ];

  /// The eyes are drawn after the layers up to the body shading.
  static final int _eyesAfter = _dashLayers.indexWhere(
    (l) => l.$1 == _Layer.nearEye,
  );

  static final _nearEye = _Eye(
    white: _parseSvgPath(
      _dashLayers.firstWhere((l) => l.$1 == _Layer.nearEye).$2,
    ),
    top: 44.3,
    bottom: 87.2,
    pupil: Rect.fromCenter(
      center: const Offset(87.8, 64.3),
      width: 12,
      height: 26.2,
    ),
    highlight: const Offset(88.6, 57.3),
    highlightRadius: 3.4,
    lookRange: const Offset(3.5, 6),
  );

  static final _farEye = _Eye(
    // The original far eye white wraps around its pupil; fill it in.
    white: Path.combine(
      PathOperation.union,
      _parseSvgPath(_dashLayers.firstWhere((l) => l.$1 == _Layer.farEye).$2),
      Path()..addOval(
        Rect.fromCenter(center: const Offset(116, 64), width: 11, height: 26),
      ),
    ),
    top: 46.6,
    bottom: 77.4,
    pupil: Rect.fromCenter(
      center: const Offset(116, 64),
      width: 10,
      height: 24.6,
    ),
    highlight: const Offset(117, 57.5),
    highlightRadius: 3,
    lookRange: const Offset(2, 5),
  );

  /// The front wing: it's cut out of the drawing along this outline and
  /// rotated around [_wingPivot].
  static final Path _wingRegion = Path()
    ..addPolygon(const [
      Offset(-2, 41),
      Offset(14, 43),
      Offset(24, 47.5),
      Offset(32, 52.5),
      Offset(42, 59.5),
      Offset(52, 69.5),
      Offset(59, 76),
      Offset(60, 90),
      Offset(40, 90.5),
      Offset(25, 89.5),
      Offset(12, 91),
      Offset(-2, 93),
    ], true);
  static final Rect _wingBounds = _wingRegion.getBounds();
  static final Path _notWingRegion = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(const Rect.fromLTWH(-20, -20, canvasSize + 40, canvasSize + 40))
    ..addPath(_wingRegion, Offset.zero);
  static const _wingPivot = Offset(54, 84);

  /// The body circle under the wing, shown when the wing moves away.
  static const _bodyUnderWingCenter = Offset(78, 76);
  static const _bodyUnderWingRadius = 49.0;

  /// Paints the dash in the [size] x [size] square at the canvas origin.
  static void paint(
    Canvas canvas,
    double size,
    DashPalette palette,
    DashFace face,
  ) {
    canvas.save();
    final s = size / canvasSize;
    canvas.scale(s, s);

    // The wing is cut out of the original artwork, so it only swings down
    // (a down stroke) where the body behind it can be filled in.
    final wingAngle = face.wingAngle.clamp(-maxWingSwing, 0.0);
    if (wingAngle > -0.01) {
      _paintLayers(canvas, palette, face, withFace: true);
    } else {
      canvas.save();
      canvas.clipPath(_notWingRegion, doAntiAlias: false);
      _paintLayers(canvas, palette, face, withFace: true);
      canvas.restore();

      canvas.save();
      canvas.clipPath(_wingRegion, doAntiAlias: false);
      _fill.color = palette.body;
      canvas.drawCircle(_bodyUnderWingCenter, _bodyUnderWingRadius, _fill);
      _stroke
        ..color = palette.outline
        ..strokeWidth = 3.4;
      canvas.drawCircle(_bodyUnderWingCenter, _bodyUnderWingRadius, _stroke);
      canvas.translate(_wingPivot.dx, _wingPivot.dy);
      canvas.rotate(wingAngle);
      canvas.translate(-_wingPivot.dx, -_wingPivot.dy);
      canvas.clipPath(_wingRegion, doAntiAlias: false);
      _paintLayers(canvas, palette, face, withFace: false, onlyIn: _wingBounds);
      canvas.restore();
    }

    _paintSweat(canvas, palette, face);
    canvas.restore();
  }

  static void _paintLayers(
    Canvas canvas,
    DashPalette palette,
    DashFace face, {
    required bool withFace,
    Rect? onlyIn,
  }) {
    for (var i = 0; i < _layers.length; i++) {
      if (withFace && i == _eyesAfter) {
        _paintCheeks(canvas, face);
        _paintEye(canvas, palette, face, _farEye);
        _paintEye(canvas, palette, face, _nearEye);
        _paintBrows(canvas, palette, face);
      }
      final layer = _layers[i];
      if (onlyIn != null && !layer.bounds.overlaps(onlyIn)) {
        continue;
      }
      _fill.color = switch (layer.layer) {
        _Layer.beak => _beakColor,
        _Layer.beakShade => _beakShadeColor,
        _Layer.outline => palette.outline,
        _Layer.body => palette.body,
        _Layer.shade => palette.shade,
        _Layer.shine => palette.eyeWhite,
        _Layer.nearEye || _Layer.farEye => palette.eyeWhite,
      };
      canvas.drawPath(layer.path, _fill);
    }
  }

  static void _paintCheeks(Canvas canvas, DashFace face) {
    if (face.blush <= 0.01) {
      return;
    }
    _fill.color = _blush.withValues(alpha: 0.5 * face.blush.clamp(0, 1));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(74, 95), width: 16, height: 8),
      _fill,
    );
  }

  static void _paintEye(
    Canvas canvas,
    DashPalette palette,
    DashFace face,
    _Eye eye,
  ) {
    canvas.save();
    canvas.clipPath(eye.white);
    final height = eye.bottom - eye.top;
    final center = eye.pupil.center;
    final rx = eye.pupil.width / 2;

    switch (face.eyeShape) {
      case DashEyeShape.happy:
        // Lids closed, a ^ inside.
        _fill.color = palette.body;
        canvas.drawPaint(_fill);
        _stroke
          ..color = palette.outline
          ..strokeWidth = 3.6;
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - rx * 1.7, center.dy + height * 0.12)
            ..quadraticBezierTo(
              center.dx,
              center.dy - height * 0.32,
              center.dx + rx * 1.7,
              center.dy + height * 0.12,
            ),
          _stroke,
        );
        canvas.restore();
        return;
      case DashEyeShape.dizzy:
        _fill.color = palette.eyeWhite;
        canvas.drawPaint(_fill);
        _stroke
          ..color = palette.outline
          ..strokeWidth = 3.4;
        final d = rx * 1.1;
        canvas.drawLine(
          center + Offset(-d, -d),
          center + Offset(d, d),
          _stroke,
        );
        canvas.drawLine(
          center + Offset(d, -d),
          center + Offset(-d, d),
          _stroke,
        );
        canvas.restore();
        return;
      case DashEyeShape.open:
        break;
    }

    _fill.color = palette.eyeWhite;
    canvas.drawPaint(_fill);

    final look = Offset(
      face.look.dx.clamp(-1.0, 1.0) * eye.lookRange.dx,
      face.look.dy.clamp(-1.0, 1.0) * eye.lookRange.dy,
    );
    final pupilScale = face.pupilScale;
    final pupilCenter = center + look;
    _fill.color = palette.outline;
    canvas.drawOval(
      Rect.fromCenter(
        center: pupilCenter,
        width: eye.pupil.width * pupilScale,
        height: eye.pupil.height * pupilScale,
      ),
      _fill,
    );
    final highlightScale = pupilScale.clamp(0.6, 1.0);
    _fill.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
      pupilCenter + (eye.highlight - center) * highlightScale,
      eye.highlightRadius * highlightScale,
      _fill,
    );

    // The upper lid comes down when blinking.
    final open = face.eyeOpen.clamp(0.0, 1.0);
    if (open < 0.99) {
      final lidY = eye.top + height * (1 - open) - 1;
      _fill.color = palette.body;
      canvas.drawRect(
        Rect.fromLTRB(-10, eye.top - 10, canvasSize, lidY),
        _fill,
      );
      _stroke
        ..color = palette.outline
        ..strokeWidth = 3;
      if (open < 0.12) {
        // Closed: a relaxed curve near the bottom.
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - rx * 2, eye.bottom - height * 0.3)
            ..quadraticBezierTo(
              center.dx,
              eye.bottom - height * 0.12,
              center.dx + rx * 2,
              eye.bottom - height * 0.3,
            ),
          _stroke,
        );
      } else {
        canvas.drawLine(Offset(-10, lidY), Offset(canvasSize, lidY), _stroke);
      }
    }
    canvas.restore();
  }

  static void _paintBrows(Canvas canvas, DashPalette palette, DashFace face) {
    _stroke
      ..color = palette.outline
      ..strokeWidth = 4;
    final lift = face.browLift;
    // The near brow. Its inner side is on the right.
    canvas.save();
    canvas.translate(78, 36 - lift);
    canvas.rotate(-face.browTilt);
    canvas.drawPath(
      Path()
        ..moveTo(-5.8, 2.2)
        ..quadraticBezierTo(-1, -3.2, 6.2, -0.8),
      _stroke,
    );
    canvas.restore();

    // The far brow only shows when the face is expressive.
    final expressiveness = (face.browTilt.abs() * 4 + lift.abs() / 4).clamp(
      0.0,
      1.0,
    );
    if (expressiveness > 0.05) {
      _stroke.color = palette.outline.withValues(alpha: expressiveness);
      canvas.save();
      canvas.translate(115, 40 - lift);
      canvas.rotate(face.browTilt);
      canvas.drawPath(
        Path()
          ..moveTo(-4.5, 1)
          ..quadraticBezierTo(0, -2.2, 4.5, 1),
        _stroke,
      );
      canvas.restore();
    }
  }

  static void _paintSweat(Canvas canvas, DashPalette palette, DashFace face) {
    if (face.sweat <= 0.01) {
      return;
    }
    final alpha = face.sweat.clamp(0.0, 1.0);
    final drop = Path()
      ..moveTo(101, 28)
      ..quadraticBezierTo(108, 37, 105, 41)
      ..arcToPoint(
        const Offset(97, 41),
        radius: const Radius.circular(4.2),
        clockwise: true,
      )
      ..quadraticBezierTo(94, 37, 101, 28)
      ..close();
    _fill.color = _sweat.withValues(alpha: alpha);
    canvas.drawPath(drop, _fill);
    _stroke
      ..color = palette.outline.withValues(alpha: alpha)
      ..strokeWidth = 2;
    canvas.drawPath(drop, _stroke);
  }

  /// Parses the absolute M/L/C/Z path data in dash_shape.g.dart.
  static Path _parseSvgPath(String data) {
    final path = Path();
    final tokens = RegExp(r'[MLCZ]|-?\d*\.?\d+').allMatches(data).toList();
    var i = 0;
    var command = 'M';
    double next() => double.parse(tokens[i++].group(0)!);
    while (i < tokens.length) {
      final token = tokens[i].group(0)!;
      if ('MLCZ'.contains(token)) {
        command = token;
        i++;
        if (command == 'Z') {
          path.close();
          continue;
        }
      }
      switch (command) {
        case 'M':
          path.moveTo(next(), next());
          command = 'L';
        case 'L':
          path.lineTo(next(), next());
        case 'C':
          path.cubicTo(next(), next(), next(), next(), next(), next());
      }
    }
    return path;
  }
}

class _ShapeLayer {
  _ShapeLayer(this.layer, this.path) : bounds = path.getBounds();

  final _Layer layer;
  final Path path;
  final Rect bounds;
}

class _Eye {
  _Eye({
    required this.white,
    required this.top,
    required this.bottom,
    required this.pupil,
    required this.highlight,
    required this.highlightRadius,
    required this.lookRange,
  });

  final Path white;
  final double top;
  final double bottom;
  final Rect pupil;
  final Offset highlight;
  final double highlightRadius;
  final Offset lookRange;
}
