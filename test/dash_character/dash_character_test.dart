import 'dart:math';

import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_character.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_face.dart';
import 'package:flappy_dash/presentation/component/dash/character/dash_face_animator.dart';
import 'package:flutter_test/flutter_test.dart';

const _dt = 1 / 60;
const _gravity = 1400.0;

/// Moves a dash like the game does: gravity, and a jump when [jumpAt]
/// says so. Returns how many flaps the character noticed.
int _fly(
  DashCharacter character, {
  required double seconds,
  bool Function(int frame)? jumpAt,
}) {
  var y = 0.0;
  var vy = 0.0;
  var flaps = 0;
  var lastWing = character.animator.face.wingAngle;
  final frames = (seconds / _dt).round();
  for (var i = 0; i < frames; i++) {
    if (jumpAt?.call(i) ?? false) {
      vy = -500;
    }
    vy += _gravity * _dt;
    y += vy * _dt;
    final before = character.expression;
    character.update(_dt, y: y, state: PlayingState.playing);
    if (before != DashExpression.determined &&
        character.expression == DashExpression.determined) {
      flaps++;
    }
    lastWing = character.animator.face.wingAngle;
  }
  expect(lastWing.isFinite, isTrue);
  return flaps;
}

void main() {
  group('DashCharacter', () {
    test('notices every jump from the movement alone', () {
      final character = DashCharacter(DashType.flutterDash);
      // A jump every 0.4s for 4s: 10 jumps.
      final flaps = _fly(
        character,
        seconds: 4,
        jumpAt: (frame) => frame % 24 == 0,
      );
      expect(flaps, 10);
    });

    test('falling without jumping is not a flap, and gets scary', () {
      final character = DashCharacter(DashType.limeDash);
      final flaps = _fly(character, seconds: 1);
      expect(flaps, 0);
      expect(character.expression, DashExpression.scared);
    });

    test('a teleport (respawn, world wrap) is not a flap', () {
      final character = DashCharacter(DashType.roseDash);
      character.update(_dt, y: 0, state: PlayingState.playing);
      character.update(_dt, y: -300, state: PlayingState.playing);
      character.update(_dt, y: -300, state: PlayingState.playing);
      expect(character.expression, DashExpression.neutral);
    });

    test('scoring is exciting for a moment', () {
      final character = DashCharacter(DashType.skyDash);
      character.update(_dt, y: 0, state: PlayingState.playing);
      character.onScored();
      character.update(_dt, y: 0, state: PlayingState.playing);
      expect(character.expression, DashExpression.excited);
      expect(character.animator.face.eyeShape, DashEyeShape.happy);
      for (var i = 0; i < 60; i++) {
        character.update(_dt, y: 0, state: PlayingState.playing);
      }
      expect(character.expression, DashExpression.neutral);
    });

    test('dizzy after a crash until the next life', () {
      final character = DashCharacter(DashType.sunnyDash);
      character.update(_dt, y: 0, state: PlayingState.playing);
      character.update(_dt, y: 0, state: PlayingState.gameOver);
      expect(character.expression, DashExpression.dizzy);
      for (var i = 0; i < 120; i++) {
        character.update(_dt, y: 0, state: PlayingState.gameOver);
      }
      expect(character.animator.face.eyeShape, DashEyeShape.dizzy);
      character.update(_dt, y: 0, state: PlayingState.idle);
      expect(character.expression, DashExpression.neutral);
    });
  });

  group('DashFaceAnimator', () {
    test('blinks on its own every few seconds', () {
      final animator = DashFaceAnimator(random: Random(1));
      var closedFrames = 0;
      for (var i = 0; i < 60 * 10; i++) {
        animator.update(_dt);
        if (animator.face.eyeOpen < 0.3) {
          closedFrames++;
        }
      }
      expect(closedFrames, greaterThan(0));
      // Mostly open though.
      expect(closedFrames, lessThan(60));
    });

    test('a flap swings the wing and it settles back', () {
      final animator = DashFaceAnimator(random: Random(1));
      animator.flap();
      var lowest = 0.0;
      for (var i = 0; i < 10; i++) {
        animator.update(_dt);
        lowest = min(lowest, animator.face.wingAngle);
      }
      expect(lowest, lessThan(-0.2));
      for (var i = 0; i < 120; i++) {
        animator.update(_dt);
      }
      expect(animator.face.wingAngle.abs(), lessThan(0.01));
    });
  });
}
