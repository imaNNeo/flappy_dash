import 'dart:ui';

import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';

import 'dash_face_animator.dart';
import 'dash_painter.dart';
import 'dash_palette.dart';

export 'dash_face_animator.dart' show DashExpression;

/// The look and the emotions of an in-game dash, drawn with code.
///
/// [Dash] owns one, calls [update] every frame with where it is, and calls
/// [render] to draw it. It works out the flaps, the scares and the crashes
/// from the movement and the playing state, so it behaves the same for our
/// own dash and for the other players' dashes. Game events it can't see
/// (scoring) come in through [onScored].
///
/// It draws inside the dash's own box, so squash/stretch, tilt or any other
/// transform applied to the canvas before [render] applies to the drawing.
class DashCharacter {
  DashCharacter(this.type) : palette = DashPalette.of(type);

  final DashType type;
  final DashPalette palette;
  final DashFaceAnimator animator = DashFaceAnimator();

  /// The expression the dash goes back to after a reaction.
  DashExpression get mood => animator.mood;

  set mood(DashExpression value) => animator.mood = value;

  /// The expression on the face right now.
  DashExpression get expression => animator.expression;

  /// Falling faster than this (units/second) is scary.
  static const scaredFallSpeed = 520.0;

  /// A jump sets the speed to -500, gravity only adds to it. A drop this
  /// big within [_flapWindow] can only be a jump.
  static const _flapSpeedDrop = 320.0;
  static const _flapWindow = 0.12;

  double? _lastY;
  double _velocityY = 0;
  double _windowStartVelocity = 0;
  double _windowTime = 0;
  double _flapCooldown = 0;
  PlayingState? _lastState;

  /// The last vertical speed worked out from the movement.
  double get velocityY => _velocityY;

  void update(double dt, {required double y, required PlayingState state}) {
    if (dt > 0) {
      _trackMovement(dt, y, state);
      _trackState(state);
    }
    animator.update(dt);
  }

  void _trackMovement(double dt, double y, PlayingState state) {
    final lastY = _lastY;
    _lastY = y;
    if (lastY == null) {
      return;
    }
    final vy = (y - lastY) / dt;
    if (vy.abs() > 3000) {
      // Teleported (respawn, the world looping), not a real movement.
      _windowStartVelocity = _velocityY = 0;
      _windowTime = 0;
      return;
    }
    _velocityY = vy;
    _flapCooldown -= dt;
    _windowTime += dt;
    if (state.isPlaying &&
        _flapCooldown <= 0 &&
        vy < _windowStartVelocity - _flapSpeedDrop) {
      onJumped();
    }
    if (_windowTime >= _flapWindow) {
      _windowTime = 0;
      _windowStartVelocity = vy;
    }

    // Eyes follow the movement: up when rising, down when falling.
    final lookY = state.isPlaying ? (vy / 700).clamp(-1.0, 1.0) : 0.0;
    animator.lookTarget = Offset(0.35, lookY);

    final scared = state.isPlaying && vy > scaredFallSpeed;
    if (scared && animator.mood == DashExpression.neutral) {
      animator.mood = DashExpression.scared;
    } else if (!scared && animator.mood == DashExpression.scared) {
      animator.mood = DashExpression.neutral;
    }
  }

  void _trackState(PlayingState state) {
    final last = _lastState;
    _lastState = state;
    if (last == null || last == state) {
      return;
    }
    if (state.isGameOver) {
      onDied();
    } else if (last.isGameOver) {
      onRespawned();
    }
  }

  /// A jump: flap and look focused for a moment.
  void onJumped() {
    _flapCooldown = 0.15;
    _windowStartVelocity = -500;
    _windowTime = 0;
    animator.flap();
    if (animator.expression != DashExpression.excited) {
      animator.react(DashExpression.determined, duration: 0.3);
    }
  }

  /// Passed a pipe.
  void onScored() {
    animator.react(DashExpression.excited, duration: 0.7);
  }

  /// Crashed: dizzy until [onRespawned].
  void onDied() {
    animator.clearReaction();
    animator.mood = DashExpression.dizzy;
  }

  void onRespawned() {
    animator.clearReaction();
    animator.mood = DashExpression.neutral;
    animator.blink();
  }

  /// Draws the dash in the [width] x [height] box at the canvas origin
  /// (the drawing is square, it's centered in the box).
  void render(Canvas canvas, double width, double height) {
    final size = width < height ? width : height;
    if (width == height) {
      DashPainter.paint(canvas, size, palette, animator.face);
      return;
    }
    canvas.save();
    canvas.translate((width - size) / 2, (height - size) / 2);
    DashPainter.paint(canvas, size, palette, animator.face);
    canvas.restore();
  }
}
