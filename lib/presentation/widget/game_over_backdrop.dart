import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The dimmed, blurred backdrop behind the game over / died messages.
///
/// It waits a moment before fading in, so the death itself (the hit flash,
/// feathers, shockwave and tumble) is seen instead of being blurred away
/// instantly, then the content pops in.
///
/// With [rehearsal], it is drawn almost transparent, without animations,
/// for two frames, once per app run, then disappears. Put it on screen
/// before the player can die: on the web the blur compiles its GPU programs
/// the first time it's drawn, which otherwise stuttered the game over
/// screen's fade in.
class GameOverBackdrop extends StatelessWidget {
  const GameOverBackdrop({
    super.key,
    required this.child,
    this.rehearsal = false,
  });

  final Widget child;
  final bool rehearsal;

  static const delay = Duration(milliseconds: 1400);
  static const fadeDuration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    if (rehearsal) {
      return _Rehearsal(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: ColoredBox(
            color: Colors.black54,
            child: SafeArea(
              minimum: const EdgeInsets.all(24),
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: child),
              ),
            ),
          ),
        ),
      );
    }
    return Animate(
      effects: [
        // Fade a fixed blur in. Animating the blur radius instead makes the
        // GPU build a new blur for every radius (a stutter on the web).
        FadeEffect(
          delay: delay,
          duration: fadeDuration,
          curve: Curves.easeOut,
          begin: 0,
          end: 1,
        ),
      ],
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: ColoredBox(color: Colors.black54, child: _content()),
      ),
    );
  }

  Widget _content() {
    return SafeArea(
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
    );
  }
}

class _Rehearsal extends StatefulWidget {
  const _Rehearsal({required this.child});

  final Widget child;

  @override
  State<_Rehearsal> createState() => _RehearsalState();
}

class _RehearsalState extends State<_Rehearsal> {
  static bool _done = false;
  int _framesLeft = 2;

  @override
  void initState() {
    super.initState();
    if (!_done) {
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration _) {
    if (!mounted) {
      return;
    }
    _framesLeft--;
    if (_framesLeft > 0) {
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
      // Make sure there is a next frame even if nothing else moves.
      WidgetsBinding.instance.scheduleFrame();
      return;
    }
    _done = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(child: Opacity(opacity: 0.02, child: widget.child));
  }
}
