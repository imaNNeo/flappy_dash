import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The dimmed, blurred backdrop behind the game over / died messages.
///
/// It waits a moment before fading in, so the death itself (the hit flash,
/// feathers, shockwave and tumble) is seen instead of being blurred away
/// instantly, then the content pops in.
class GameOverBackdrop extends StatelessWidget {
  const GameOverBackdrop({super.key, required this.child});

  final Widget child;

  static const delay = Duration(milliseconds: 650);
  static const fadeDuration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        CustomEffect(
          delay: delay,
          duration: fadeDuration,
          curve: Curves.easeOut,
          builder: (context, value, child) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6 * value, sigmaY: 6 * value),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.54 * value),
              child: child,
            ),
          ),
        ),
      ],
      child: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child
                .animate(delay: delay)
                .fadeIn(duration: 200.ms)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
          ),
        ),
      ),
    );
  }
}
