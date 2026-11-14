import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_face_animator.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_painter.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

export 'package:flappy_dash/presentation/component/dash/character/dash_face_animator.dart'
    show DashExpression;

/// A dash drawn with code (no image asset), [size] x [size].
///
/// When [animated] it blinks now and then and eases into [expression]
/// whenever it changes.
class DashImage extends StatefulWidget {
  const DashImage({
    super.key,
    required this.size,
    required this.type,
    this.expression = DashExpression.neutral,
    this.animated = true,
  });

  final double size;
  final DashType type;
  final DashExpression expression;
  final bool animated;

  @override
  State<DashImage> createState() => _DashImageState();
}

class _DashImageState extends State<DashImage>
    with SingleTickerProviderStateMixin {
  late final DashFaceAnimator _animator;
  late final ValueNotifier<int> _frame;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animator = DashFaceAnimator()..mood = widget.expression;
    // Start on the expression instead of easing into it.
    _animator.update(1);
    _frame = ValueNotifier(0);
    _updateTicker();
  }

  @override
  void didUpdateWidget(covariant DashImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animator.mood = widget.expression;
    if (!widget.animated) {
      _animator.update(1);
      _frame.value++;
    }
    _updateTicker();
  }

  void _updateTicker() {
    if (widget.animated && _ticker == null) {
      _lastTick = Duration.zero;
      _ticker = createTicker(_onTick)..start();
    } else if (!widget.animated && _ticker != null) {
      _ticker!.dispose();
      _ticker = null;
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _animator.update(dt.clamp(0.0, 0.1));
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _DashFacePainter(
          palette: DashPalette.of(widget.type),
          animator: _animator,
          repaint: _frame,
        ),
      ),
    );
  }
}

class _DashFacePainter extends CustomPainter {
  _DashFacePainter({
    required this.palette,
    required this.animator,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final DashPalette palette;
  final DashFaceAnimator animator;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    DashPainter.paint(canvas, s, palette, animator.face);
  }

  @override
  bool shouldRepaint(covariant _DashFacePainter oldDelegate) =>
      oldDelegate.palette != palette || oldDelegate.animator != animator;
}

/// Four dashes in a group (the multiplayer button).
class MultiDashImage extends StatelessWidget {
  const MultiDashImage({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final d = height * 0.5;
    return SizedBox(
      width: height * 0.95,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: height * 0.4,
            top: 0,
            child: DashImage(size: d, type: DashType.flutterDash),
          ),
          Positioned(
            left: 0,
            top: height * 0.14,
            child: DashImage(size: d, type: DashType.scarletDash),
          ),
          Positioned(
            left: height * 0.43,
            top: height * 0.48,
            child: DashImage(size: d, type: DashType.roseDash),
          ),
          Positioned(
            left: 0,
            top: height * 0.53,
            child: DashImage(size: d, type: DashType.sunnyDash),
          ),
        ],
      ),
    );
  }
}
