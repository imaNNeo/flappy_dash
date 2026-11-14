import 'dart:math';
import 'dart:ui';

import 'dash_face.dart';

/// The moods a dash can show. Each one is a target [DashFace] that the
/// [DashFaceAnimator] eases into.
enum DashExpression {
  /// Calm, looking ahead, blinking now and then.
  neutral,

  /// Just flapped: focused brows.
  determined,

  /// Just scored: ^ ^ eyes, open beak, pink cheeks.
  excited,

  /// Content smile (menus, the winner on the results page).
  happy,

  /// Falling fast: wide eyes, tiny pupils, a sweat drop.
  scared,

  /// Crashed: X X eyes.
  dizzy,
}

/// Animates a [DashFace]: random blinking, easing between expressions,
/// short reactions (score, flap), the wing flap and where the eyes look.
///
/// It's plain Dart (no Flame / widgets), so the in-game dash and the
/// Flutter widgets share it. Call [update] every frame and draw [face].
class DashFaceAnimator {
  DashFaceAnimator({Random? random}) : _random = random ?? Random() {
    _nextBlinkIn = _randomBlinkDelay();
    _applyTarget(_target, mood);
    face.copyFrom(_target);
  }

  final Random _random;

  /// The face to draw.
  final DashFace face = DashFace();

  /// The expression the dash goes back to when no reaction is playing.
  DashExpression mood = DashExpression.neutral;

  DashExpression? _reaction;
  double _reactionTimeLeft = 0;

  /// The expression on the face right now.
  DashExpression get expression => _reaction ?? mood;

  /// Shows [expression] for [duration] seconds, then goes back to [mood].
  void react(DashExpression expression, {double duration = 0.6}) {
    _reaction = expression;
    _reactionTimeLeft = duration;
  }

  void clearReaction() {
    _reaction = null;
    _reactionTimeLeft = 0;
  }

  /// Where the eyes look, each axis in -1..1 (positive y is down).
  Offset lookTarget = const Offset(0.35, 0);

  // Blinking
  double _nextBlinkIn = 0;
  double _blinkTime = -1;
  static const _blinkDuration = 0.16;

  /// Blinks right now (it also blinks on its own every few seconds).
  void blink() {
    _blinkTime = 0;
  }

  double _randomBlinkDelay() => 1.8 + _random.nextDouble() * 3.2;

  // The front wing is a damped spring.
  double _wingVelocity = 0;
  static const _wingStiffness = 220.0;
  static const _wingDamping = 13.0;

  /// A wing stroke (a jump).
  void flap() {
    _wingVelocity = -13;
  }

  final DashFace _target = DashFace();

  void update(double dt) {
    if (dt <= 0) {
      return;
    }
    if (_reaction != null) {
      _reactionTimeLeft -= dt;
      if (_reactionTimeLeft <= 0) {
        _reaction = null;
      }
    }
    final current = expression;
    _applyTarget(_target, current);

    // Ease every value towards the target.
    final t = 1 - exp(-dt * 16);
    double ease(double from, double to) => from + (to - from) * t;
    face
      ..eyeShape = _target.eyeShape
      ..eyeScale = ease(face.eyeScale, _target.eyeScale)
      ..pupilScale = ease(face.pupilScale, _target.pupilScale)
      ..browLift = ease(face.browLift, _target.browLift)
      ..browTilt = ease(face.browTilt, _target.browTilt)
      ..beakOpen = ease(face.beakOpen, _target.beakOpen)
      ..blush = ease(face.blush, _target.blush)
      ..sweat = ease(face.sweat, _target.sweat);
    face.look = Offset(
      ease(face.look.dx, _target.look.dx),
      ease(face.look.dy, _target.look.dy),
    );

    // Blinking (only with open eyes).
    var eyeOpen = _target.eyeOpen;
    if (_blinkTime >= 0) {
      _blinkTime += dt;
      final p = _blinkTime / _blinkDuration;
      if (p >= 1) {
        _blinkTime = -1;
      } else {
        // Close fast, open a bit slower.
        final closed = p < 0.4 ? p / 0.4 : 1 - (p - 0.4) / 0.6;
        eyeOpen *= 1 - closed;
      }
    } else if (_target.eyeShape == DashEyeShape.open) {
      _nextBlinkIn -= dt;
      if (_nextBlinkIn <= 0) {
        blink();
        // Sometimes a double blink.
        _nextBlinkIn = _random.nextDouble() < 0.2
            ? _blinkDuration + 0.08
            : _randomBlinkDelay();
      }
    }
    face.eyeOpen = _blinkTime >= 0 ? eyeOpen : ease(face.eyeOpen, eyeOpen);

    // Wing spring towards the expression's resting angle.
    final steps = (dt / (1 / 120)).ceil().clamp(1, 8);
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      final force =
          -_wingStiffness * (face.wingAngle - _target.wingAngle) -
          _wingDamping * _wingVelocity;
      _wingVelocity += force * h;
      face.wingAngle += _wingVelocity * h;
    }
  }

  void _applyTarget(DashFace target, DashExpression expression) {
    target
      ..eyeShape = DashEyeShape.open
      ..eyeOpen = 1
      ..eyeScale = 1
      ..pupilScale = 1
      ..look = lookTarget
      ..browLift = 0
      ..browTilt = 0
      ..beakOpen = 0
      ..blush = 0
      ..sweat = 0
      ..wingAngle = 0;
    switch (expression) {
      case DashExpression.neutral:
        break;
      case DashExpression.determined:
        target
          ..eyeOpen = 0.82
          ..browLift = -2
          ..browTilt = -0.32;
      case DashExpression.excited:
        target
          ..eyeShape = DashEyeShape.happy
          ..browLift = 3
          ..beakOpen = 0.9
          ..blush = 1
          ..wingAngle = 0.25;
      case DashExpression.happy:
        target
          ..eyeShape = DashEyeShape.happy
          ..browLift = 2
          ..blush = 0.7;
      case DashExpression.scared:
        target
          ..eyeScale = 1.12
          ..pupilScale = 0.6
          ..browLift = 4
          ..browTilt = 0.35
          ..beakOpen = 0.45
          ..sweat = 1
          ..wingAngle = 0.5;
      case DashExpression.dizzy:
        target
          ..eyeShape = DashEyeShape.dizzy
          ..look = Offset.zero
          ..browLift = 2
          ..browTilt = 0.2
          ..beakOpen = 0.55
          ..wingAngle = -0.3;
    }
  }
}
