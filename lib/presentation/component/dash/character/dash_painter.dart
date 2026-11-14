import 'dart:math';
import 'dart:ui';

import 'dash_face.dart';
import 'dash_palette.dart';

/// Draws a dash (the bird) with code: no image assets. The drawing looks
/// right (beak to the right) and fills a [canvasSize] x [canvasSize] square,
/// which [paint] scales to any size.
///
/// The face (eyes, brows, beak, cheeks) and the front wing come from a
/// [DashFace], so the same drawing can blink, smile, get scared, etc.
class DashPainter {
  DashPainter._();

  /// The size of the drawing in its own units.
  static const double canvasSize = 138;

  static const _bodyCenter = Offset(76, 73);
  static const _bodyRadius = 51.0;
  static const _outlineWidth = 3.4;

  /// Where the front wing is attached (it rotates around this point).
  static const _wingPivot = Offset(56, 76);

  /// The near eye (the big one) and the far eye (partly behind the head).
  static const _nearEye = _Eye(
    center: Offset(80, 64),
    radiusX: 16,
    radiusY: 22,
    pupilCenter: Offset(86, 62),
    pupilRadiusX: 6.2,
    pupilRadiusY: 10,
    highlight: Offset(88.4, 56.5),
    highlightRadius: 2.9,
    lookRange: Offset(4.5, 7),
  );
  static const _farEye = _Eye(
    center: Offset(117, 64),
    radiusX: 10.5,
    radiusY: 19,
    pupilCenter: Offset(117.5, 62),
    pupilRadiusX: 5.2,
    pupilRadiusY: 9.5,
    highlight: Offset(119.4, 56.5),
    highlightRadius: 2.4,
    lookRange: Offset(2.5, 6),
  );

  static const _beakHinge = Offset(98, 89);
  static const _beakYellow = Color(0xFFFABC01);
  static const _beakLight = Color(0xFFFFD84D);
  static const _beakLower = Color(0xFFF79A0A);
  static const _beakLine = Color(0xFFFF560F);
  static const _mouth = Color(0xFF8C1D2B);
  static const _blush = Color(0xFFFF5C8A);
  static const _sweat = Color(0xFF9EE6FF);

  static final _fill = Paint()..isAntiAlias = true;
  static final _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Path _tuft = _buildTuft();
  static final Path _upperBeak = Path()
    ..moveTo(92, 79)
    ..quadraticBezierTo(113, 67, 133, 83)
    ..quadraticBezierTo(136, 88, 129, 89.5)
    ..lineTo(99, 90)
    ..quadraticBezierTo(89, 88, 92, 79)
    ..close();
  static final Path _upperBeakLight = Path()
    ..moveTo(97, 79.5)
    ..quadraticBezierTo(113, 71, 127, 80)
    ..quadraticBezierTo(112, 77, 97, 82)
    ..close();
  static final Path _lowerBeak = Path()
    ..moveTo(96, 88)
    ..lineTo(127, 89)
    ..quadraticBezierTo(121, 98, 104, 98.5)
    ..quadraticBezierTo(94, 97, 96, 88)
    ..close();
  static final Path _mouthPath = Path()
    ..moveTo(96, 88)
    ..lineTo(127, 89)
    ..lineTo(96, 96)
    ..close();

  static Path _buildTuft() {
    final path = Path()
      ..moveTo(56, 30)
      ..cubicTo(40, 28, 44, 14, 56, 13)
      ..cubicTo(68, 12, 79, 16, 86, 26)
      ..lineTo(70, 30)
      ..close();
    return path;
  }

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
    _stroke.strokeWidth = _outlineWidth;

    _paintBackFeathers(canvas, palette);
    _paintTuft(canvas, palette);
    _paintBody(canvas, palette);
    _paintCheeks(canvas, face);
    _paintEye(canvas, palette, face, _farEye);
    _paintEye(canvas, palette, face, _nearEye);
    _paintBrows(canvas, palette, face);
    _paintBeak(canvas, palette, face);
    _paintFrontWing(canvas, palette, face);
    _paintSweat(canvas, palette, face);

    canvas.restore();
  }

  static void _paintBackFeathers(Canvas canvas, DashPalette palette) {
    // Upper wing, behind the body.
    _paintFeather(canvas, palette, const Offset(58, 50), 226, 40, 15);
    _paintFeather(canvas, palette, const Offset(56, 56), 210, 40, 15);
    // Tail, behind the body.
    _paintFeather(canvas, palette, const Offset(46, 90), 162, 42, 14);
    _paintFeather(canvas, palette, const Offset(46, 95), 148, 36, 13);
  }

  static void _paintFrontWing(
    Canvas canvas,
    DashPalette palette,
    DashFace face,
  ) {
    canvas.save();
    canvas.translate(_wingPivot.dx, _wingPivot.dy);
    canvas.rotate(face.wingAngle);
    canvas.translate(-_wingPivot.dx, -_wingPivot.dy);
    _paintFeather(
      canvas,
      palette,
      _wingPivot + const Offset(-2, 9),
      174,
      40,
      17,
    );
    _paintFeather(
      canvas,
      palette,
      _wingPivot + const Offset(-1, 4),
      189,
      47,
      18,
    );
    _paintFeather(canvas, palette, _wingPivot, 204, 53, 20);
    // The shoulder that hides where the feathers start.
    final shoulder = Rect.fromCenter(
      center: _wingPivot + const Offset(-3, 4),
      width: 16,
      height: 24,
    );
    _fill.color = palette.body;
    canvas.drawOval(shoulder, _fill);
    _stroke.color = palette.outline;
    canvas.drawArc(shoulder, -pi * 0.55, pi * 1.05, false, _stroke);
    canvas.restore();
  }

  /// A rounded feather that starts at [root] and points at [angleDeg].
  static void _paintFeather(
    Canvas canvas,
    DashPalette palette,
    Offset root,
    double angleDeg,
    double length,
    double width,
  ) {
    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.rotate(angleDeg * pi / 180);
    final feather = _featherPath(length, width);
    _fill.color = palette.shade;
    canvas.drawPath(feather, _fill);
    // The lit upper part. Feathers point left, so after the rotation "up" on
    // screen is +y in this local space.
    canvas.save();
    canvas.clipPath(feather);
    _fill.color = palette.body;
    canvas.drawPath(feather.shift(Offset(-2, width * 0.28)), _fill);
    canvas.restore();
    _stroke.color = palette.outline;
    canvas.drawPath(feather, _stroke);
    canvas.restore();
  }

  static final _featherPaths = <int, Path>{};

  /// Narrow at the root, round at the tip, pointing right (+x). Cached, the
  /// same few sizes are drawn every frame.
  static Path _featherPath(double length, double width) =>
      _featherPaths.putIfAbsent(
        (length * 1000 + width).round(),
        () => Path()
          ..moveTo(-4, -width * 0.32)
          ..cubicTo(
            length * 0.45,
            -width * 0.62,
            length,
            -width * 0.58,
            length,
            0,
          )
          ..cubicTo(
            length,
            width * 0.58,
            length * 0.45,
            width * 0.62,
            -4,
            width * 0.32,
          )
          ..close(),
      );

  static void _paintTuft(Canvas canvas, DashPalette palette) {
    _fill.color = palette.body;
    canvas.drawPath(_tuft, _fill);
    _stroke.color = palette.outline;
    canvas.drawPath(_tuft, _stroke);
    // Shine on top of the tuft.
    _stroke
      ..color = palette.eyeWhite
      ..strokeWidth = 2.6;
    canvas.drawPath(
      Path()
        ..moveTo(50, 21)
        ..quadraticBezierTo(54, 16, 64, 16.5),
      _stroke,
    );
    _stroke.strokeWidth = _outlineWidth;
  }

  static void _paintBody(Canvas canvas, DashPalette palette) {
    final body = Rect.fromCircle(center: _bodyCenter, radius: _bodyRadius);
    _fill.color = palette.shade;
    canvas.drawOval(body, _fill);
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    _fill.color = palette.body;
    canvas.drawCircle(
      _bodyCenter + const Offset(7, -9),
      _bodyRadius - 2,
      _fill,
    );
    canvas.restore();
    // Shine along the top left of the head.
    _stroke
      ..color = palette.eyeWhite.withValues(alpha: 0.9)
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: _bodyCenter, radius: _bodyRadius - 6),
      pi * 1.12,
      pi * 0.3,
      false,
      _stroke,
    );
    _stroke
      ..strokeWidth = _outlineWidth
      ..color = palette.outline;
    canvas.drawOval(body, _stroke);
  }

  static void _paintCheeks(Canvas canvas, DashFace face) {
    if (face.blush <= 0.01) {
      return;
    }
    _fill.color = _blush.withValues(alpha: 0.55 * face.blush.clamp(0, 1));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(73, 94), width: 15, height: 8),
      _fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(124, 93), width: 7, height: 6),
      _fill,
    );
  }

  static void _paintEye(
    Canvas canvas,
    DashPalette palette,
    DashFace face,
    _Eye eye,
  ) {
    final rx = eye.radiusX * face.eyeScale;
    switch (face.eyeShape) {
      case DashEyeShape.happy:
        // ^ shaped closed eyes.
        _stroke
          ..color = palette.outline
          ..strokeWidth = 4;
        canvas.drawPath(
          Path()
            ..moveTo(eye.center.dx - rx * 0.75, eye.center.dy + 6)
            ..quadraticBezierTo(
              eye.center.dx,
              eye.center.dy - 12,
              eye.center.dx + rx * 0.75,
              eye.center.dy + 6,
            ),
          _stroke,
        );
        _stroke.strokeWidth = _outlineWidth;
        return;
      case DashEyeShape.dizzy:
        final rect = Rect.fromCenter(
          center: eye.center,
          width: rx * 2,
          height: eye.radiusY * 2 * face.eyeScale,
        );
        _fill.color = palette.eyeWhite;
        canvas.drawOval(rect, _fill);
        _stroke.color = palette.outline;
        canvas.drawOval(rect, _stroke);
        final d = rx * 0.5;
        _stroke.strokeWidth = 3.6;
        final c = eye.center;
        canvas.drawLine(c + Offset(-d, -d), c + Offset(d, d), _stroke);
        canvas.drawLine(c + Offset(d, -d), c + Offset(-d, d), _stroke);
        _stroke.strokeWidth = _outlineWidth;
        return;
      case DashEyeShape.open:
        break;
    }

    final open = face.eyeOpen.clamp(0.0, 1.0);
    if (open < 0.18) {
      // Closed: a relaxed line.
      _stroke
        ..color = palette.outline
        ..strokeWidth = 3.6;
      canvas.drawPath(
        Path()
          ..moveTo(eye.center.dx - rx * 0.8, eye.center.dy + 2)
          ..quadraticBezierTo(
            eye.center.dx,
            eye.center.dy + 7,
            eye.center.dx + rx * 0.8,
            eye.center.dy + 2,
          ),
        _stroke,
      );
      _stroke.strokeWidth = _outlineWidth;
      return;
    }

    final ry = eye.radiusY * face.eyeScale * open;
    // Blinking keeps the bottom of the eye in place.
    final centerY = eye.center.dy + eye.radiusY * face.eyeScale * (1 - open);
    final rect = Rect.fromCenter(
      center: Offset(eye.center.dx, centerY),
      width: rx * 2,
      height: ry * 2,
    );
    _fill.color = palette.eyeWhite;
    canvas.drawOval(rect, _fill);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final look = Offset(
      face.look.dx.clamp(-1.0, 1.0) * eye.lookRange.dx,
      face.look.dy.clamp(-1.0, 1.0) * eye.lookRange.dy,
    );
    final pupilCenter =
        Offset(
          eye.pupilCenter.dx,
          centerY + (eye.pupilCenter.dy - eye.center.dy) * open,
        ) +
        look;
    _fill.color = palette.outline;
    canvas.drawOval(
      Rect.fromCenter(
        center: pupilCenter,
        width: eye.pupilRadiusX * 2 * face.pupilScale,
        height: eye.pupilRadiusY * 2 * face.pupilScale,
      ),
      _fill,
    );
    _fill.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
      pupilCenter +
          (eye.highlight - eye.pupilCenter) * face.pupilScale.clamp(0.6, 1.0),
      eye.highlightRadius * face.pupilScale.clamp(0.7, 1.0),
      _fill,
    );
    canvas.restore();

    _stroke.color = palette.outline;
    canvas.drawOval(rect, _stroke);
  }

  static void _paintBrows(Canvas canvas, DashPalette palette, DashFace face) {
    _stroke
      ..color = palette.outline
      ..strokeWidth = 3.4;
    final lift = face.browLift;
    // The near brow. Its inner side is on the right.
    canvas.save();
    canvas.translate(78, 37 - lift);
    canvas.rotate(-face.browTilt);
    canvas.drawPath(
      Path()
        ..moveTo(-6.5, 1.2)
        ..quadraticBezierTo(0, -3, 6.5, 1.2),
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
      canvas.translate(116, 40 - lift);
      canvas.rotate(face.browTilt);
      canvas.drawPath(
        Path()
          ..moveTo(-4.5, 1)
          ..quadraticBezierTo(0, -2.2, 4.5, 1),
        _stroke,
      );
      canvas.restore();
    }
    _stroke.strokeWidth = _outlineWidth;
  }

  static void _paintBeak(Canvas canvas, DashPalette palette, DashFace face) {
    final open = face.beakOpen.clamp(0.0, 1.0);
    _stroke.color = palette.outline;
    if (open > 0.01) {
      _fill.color = _mouth;
      canvas.save();
      canvas.translate(_beakHinge.dx, _beakHinge.dy);
      canvas.rotate(open * 0.22);
      canvas.translate(-_beakHinge.dx, -_beakHinge.dy);
      canvas.drawPath(_mouthPath, _fill);
      canvas.restore();
    }
    // Lower beak, rotates open around the hinge.
    canvas.save();
    canvas.translate(_beakHinge.dx, _beakHinge.dy);
    canvas.rotate(open * 0.45);
    canvas.translate(-_beakHinge.dx, -_beakHinge.dy);
    _fill.color = _beakLower;
    canvas.drawPath(_lowerBeak, _fill);
    canvas.drawPath(_lowerBeak, _stroke);
    canvas.restore();

    _fill.color = _beakYellow;
    canvas.drawPath(_upperBeak, _fill);
    _fill.color = _beakLight;
    canvas.drawPath(_upperBeakLight, _fill);
    _stroke.color = palette.outline;
    canvas.drawPath(_upperBeak, _stroke);
    if (open <= 0.01) {
      _stroke
        ..color = _beakLine
        ..strokeWidth = 2;
      canvas.drawLine(const Offset(101, 91.5), const Offset(124, 91), _stroke);
      _stroke.strokeWidth = _outlineWidth;
    }
  }

  static void _paintSweat(Canvas canvas, DashPalette palette, DashFace face) {
    if (face.sweat <= 0.01) {
      return;
    }
    final alpha = face.sweat.clamp(0.0, 1.0);
    final drop = Path()
      ..moveTo(101, 30)
      ..quadraticBezierTo(108, 39, 105, 43)
      ..arcToPoint(
        const Offset(97, 43),
        radius: const Radius.circular(4.2),
        clockwise: true,
      )
      ..quadraticBezierTo(94, 39, 101, 30)
      ..close();
    _fill.color = _sweat.withValues(alpha: alpha);
    canvas.drawPath(drop, _fill);
    _stroke
      ..color = palette.outline.withValues(alpha: alpha)
      ..strokeWidth = 2;
    canvas.drawPath(drop, _stroke);
    _stroke.strokeWidth = _outlineWidth;
  }
}

class _Eye {
  const _Eye({
    required this.center,
    required this.radiusX,
    required this.radiusY,
    required this.pupilCenter,
    required this.pupilRadiusX,
    required this.pupilRadiusY,
    required this.highlight,
    required this.highlightRadius,
    required this.lookRange,
  });

  final Offset center;
  final double radiusX;
  final double radiusY;
  final Offset pupilCenter;
  final double pupilRadiusX;
  final double pupilRadiusY;
  final Offset highlight;
  final double highlightRadius;
  final Offset lookRange;
}
