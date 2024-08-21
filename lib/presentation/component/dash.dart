import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

import 'hidden_coin.dart';

class Dash extends PositionComponent
    with
        CollisionCallbacks,
        HasGameRef<FlappyDashGame>,
        FlameBlocReader<GameCubit, GameState> {
  Dash({
    required super.position,
    required this.isMe,
    required this.userId,
    this.speed = 200.0,
  }) : super(
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: isMe ? 10 : 9,
        );

  final bool isMe;
  final String userId;
  late Sprite _dashSprite;

  final Vector2 _gravity = Vector2(0, 1400.0);
  Vector2 _velocity = Vector2(0, 0);
  final Vector2 _jumpForce = Vector2(0, -500);
  final double speed;

  static const _correctPositionEvery = 0.1;
  double correctPositionAfter = _correctPositionEvery;


  static const _printTestLogEvery = 1.0;
  double printTestLogAfter = _printTestLogEvery;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    int colorIndex = 0;
    if (isMe) {
      colorIndex = bloc.state.currentUserId == null
          ? 0
          : bloc.state.currentUserId.hashCode % 7;
    } else {
      colorIndex = userId.hashCode % 7;
    }
    _dashSprite = await Sprite.load(switch (colorIndex) {
      0 => 'dash.png',
      1 => 'dash_black.png',
      2 => 'dash_cyan.png',
      3 => 'dash_green.png',
      4 => 'dash_orange.png',
      5 => 'dash_pink.png',
      6 => 'dash_yellow.png',
      _ => throw Exception('Invalid index'),
    });
    final radius = size.x / 2;
    final center = size / 2;
    add(CircleHitbox(
      radius: radius * 0.75,
      position: center * 1.1,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isMe) {
      if (bloc.state.currentPlayingState.isNotPlaying) {
        return;
      }
      _velocity += _gravity * dt;
      position += _velocity * dt;
      position.x += speed * dt;
      bloc.updateMyPosition(position);
      if (position.y.abs() >= gameRef.size.y) {
        bloc.gameOver();
      }

      correctPositionAfter -= dt;
      if (correctPositionAfter <= 0) {
        correctPositionAfter = _correctPositionEvery;
        bloc.sendCorrectPositionEvent(position);
      }
    } else {
      // Others
      printTestLogAfter -= dt;
      if (printTestLogAfter <= 0) {
        printTestLogAfter = _printTestLogEvery;
      }
      if (bloc.state.otherDashes[userId]!.playingState.isNotPlaying) {
        return;
      }
      _velocity += _gravity * dt;
      position += _velocity * dt;
      position.x += speed * dt;
    }
  }

  void jump() {
    if (isMe && bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    _velocity = _jumpForce;

    if (isMe) {
      bloc.sendJumpEvent(position);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSprite.render(
      canvas,
      size: size,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!isMe) {
      return;
    }
    if (bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    if (other is HiddenCoin) {
      bloc.increaseScore();
      other.removeFromParent();
    } else if (other is Pipe) {
      bloc.gameOver();
    }
  }
}
