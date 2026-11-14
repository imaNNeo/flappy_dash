import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

/// The game's main call-to-action button: a chunky, rounded "3D" button that
/// lifts a little on hover and presses down when tapped.
class BigButton extends StatefulWidget {
  const BigButton({
    super.key,
    required this.child,
    this.onPressed,
    this.bgColor = AppColors.blueButtonBgColor50,
    this.strokeColor = AppColors.blueButtonStrokeColor,
    this.showLoading = false,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color strokeColor;
  final bool showLoading;

  /// Overrides the default size, which depends on the screen size.
  final double? width;
  final double? height;

  static double defaultHeight(ScreenSize screenSize) => switch (screenSize) {
    ScreenSize.extraSmall => 58,
    ScreenSize.small => 66,
    ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 76,
  };

  static double defaultWidth(ScreenSize screenSize) => switch (screenSize) {
    ScreenSize.extraSmall => 260,
    ScreenSize.small => 300,
    ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 340,
  };

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _hovered = false;
  bool _pressed = false;

  static const _depth = 5.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final disabled = widget.onPressed == null;
    final height = widget.height ?? BigButton.defaultHeight(screenSize);
    final width = widget.width ?? BigButton.defaultWidth(screenSize);
    final radius = BorderRadius.circular(
      PresentationConstants.defaultBorderRadius,
    );
    final strokeColor = disabled
        ? widget.strokeColor.withValues(alpha: 0.3)
        : widget.strokeColor;
    final bgColor = disabled
        ? widget.bgColor.withValues(alpha: 0.3)
        : widget.bgColor;

    // How far the face sits above its shadow edge.
    final lift = disabled || _pressed ? 1.0 : (_hovered ? _depth + 1 : _depth);

    return SizedBox(
      width: width,
      height: height,
      child: MouseRegion(
        cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: Listener(
          onPointerDown: disabled
              ? null
              : (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The edge under the face, which gives the button its depth.
              // Only the part peeking out below the face is painted, so it
              // doesn't show through translucent button colors.
              Positioned.fill(
                child: CustomPaint(
                  painter: _EdgePainter(
                    color: Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.35),
                      strokeColor,
                    ),
                    radius: PresentationConstants.defaultBorderRadius,
                    depth: _depth + 1,
                    lift: lift,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: _depth + 1 - lift,
                bottom: lift,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: radius,
                      border: Border.all(color: strokeColor, width: 2.5),
                    ),
                    child: InkWell(
                      onTap: widget.onPressed,
                      borderRadius: radius,
                      splashColor: Colors.white24,
                      highlightColor: Colors.white10,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Opacity(
                              opacity: disabled ? 0.5 : 1,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.showLoading)
                Positioned.fill(
                  bottom: _depth,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: radius,
                    ),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.color,
    required this.radius,
    required this.depth,
    required this.lift,
  });

  final Color color;
  final double radius;
  final double depth;
  final double lift;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(radius);
    final edge = Path()
      ..addRRect(RRect.fromLTRBR(0, depth, size.width, size.height, r));
    final face = Path()
      ..addRRect(
        RRect.fromLTRBR(0, depth - lift, size.width, size.height - lift, r),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, edge, face),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_EdgePainter old) =>
      old.color != color || old.lift != lift || old.depth != depth;
}
