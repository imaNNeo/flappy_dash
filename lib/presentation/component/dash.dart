import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame_svg/svg.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

import 'hidden_coin.dart';
import 'outlined_text_component.dart';

class Dash extends PositionComponent
    with CollisionCallbacks, HasGameRef<FlappyDashGame> {
  Dash({
    this.speed = 200.0,
    required this.playerId,
    required this.displayName,
    required this.isMe,
  })  : type = DashType.fromUserId(playerId),
        super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: 10,
        );

  final String playerId;
  final String displayName;
  final bool isMe;
  final DashType type;
  late final Svg _dashSvg;

  final double _gravity = 1400.0;
  double _yVelocity = 0;
  final double _jumpForce = -500;
  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _dashSvg = await Svg.load(type.flameAssetName);
    final radius = size.x / 2;
    final center = size / 2;
    if (isMe) {
      add(CircleHitbox(
        radius: radius * 0.75,
        position: center * 1.1,
        anchor: Anchor.center,
        collisionType: isMe ? CollisionType.active : CollisionType.inactive,
      ));
    }
    add(OutlinedTextComponent(
      text: displayName,
      position: Vector2(size.x / 2, 0),
      textStyle: TextStyle(
        fontSize: 24,
        fontFamily: 'Chewy',
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: AppColors.getDashColor(type),
      ),
    ));
  }

  PlayingState get currentPlayingState => game.getCurrentPlayingState(
        otherPlayerId: isMe ? null : playerId,
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _yVelocity += _gravity * dt;
    position.y += _yVelocity * dt;
    position.x += speed * dt;

    _checkIfDashIsOutOfBounds();
  }

  void _checkIfDashIsOutOfBounds() {
    if (!isMe) {
      return;
    }
    if (position.y.abs() > (game.size.y / 2) + 20) {
      game.gameOver(x, y);
    }
  }

  void jump() {
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _yVelocity = _jumpForce;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSvg.render(
      canvas,
      size,
    );
  }

  void updatePosition(double dashX, double dashY) {
    assert(game.gameMode is MultiplayerGameMode && !isMe);
    x = dashX;
    y = dashY;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    if (other is HiddenCoin) {
      game.increaseScore(x, y);
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver(x, y);
    }
  }
}
