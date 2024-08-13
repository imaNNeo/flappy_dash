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
  Dash({this.speed = 200.0})
      : super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: 10,
        );

  late Sprite _dashSprite;

  final Vector2 _gravity = Vector2(0, 1400.0);
  Vector2 _velocity = Vector2(0, 0);
  final Vector2 _jumpForce = Vector2(0, -500);
  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final index = bloc.state.currentUserId == null
        ? 0
        : bloc.state.currentUserId.hashCode % 7;
    _dashSprite = await Sprite.load(switch (index) {
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
    if (bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    _velocity += _gravity * dt;
    position += _velocity * dt;
    position.x += speed * dt;
    bloc.updatePlayerPosition(position.x, position.y);

    if (position.y.abs() >= gameRef.size.y) {
      bloc.gameOver();
    }
  }

  void jump() {
    if (bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    _velocity = _jumpForce;
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
