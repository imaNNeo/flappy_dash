import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
    super.priority,
  })  : type = DashType.fromUserId(playerId),
        super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
        );

  final String playerId;
  final String displayName;
  final bool isMe;
  final DashType type;
  late final Svg _dashSvg;

  final double _gravity = 1400.0;
  double _velocityY = 0;

  double get velocityY => _velocityY;

  final double _jumpForce = -500;
  final double speed;

  late double _multiplayerCorrectPositionAfter;

  MoveToEffect? _smoothUpdatingPositionEffect;

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

    _resetCorrectPositionAfter();
  }

  void _resetCorrectPositionAfter() {
    if (game.gameMode is! MultiplayerGameMode) {
      return;
    }
    _multiplayerCorrectPositionAfter =
        (game.gameMode as MultiplayerGameMode).gameConfig.correctPositionEvery *
            0.1;
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
    if (isMe) {
      _updatePositionNormally(dt);
    } else {
      if (_smoothUpdatingPositionEffect == null) {
        _updatePositionNormally(dt);
      }
    }

    _checkIfDashIsOutOfBounds();
    _checkToDispatchMyPosition(dt);
  }

  void _updatePositionNormally(double dt) {
    _velocityY += _gravity * dt;
    position.y += _velocityY * dt;
    position.x += speed * dt;

  }

  void _checkIfDashIsOutOfBounds() {
    if (!isMe) {
      return;
    }
    if (position.y.abs() > (game.size.y / 2) + 20) {
      game.gameOver(x, y, _velocityY);
    }
  }

  void _checkToDispatchMyPosition(double dt) {
    if (!isMe) {
      return;
    }

    _multiplayerCorrectPositionAfter -= dt;
    if (_multiplayerCorrectPositionAfter > 0) {
      return;
    }
    game.multiplayerCubit.dispatchCorrectPosition(x, y, _velocityY);
    _resetCorrectPositionAfter();
  }

  void jump() {
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _velocityY = _jumpForce;
  }

  @override
  void renderTree(Canvas canvas) {
    if (!isMe && currentPlayingState.isNotPlaying) {
      return;
    }
    super.renderTree(canvas);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSvg.render(
      canvas,
      size,
    );
  }

  void resetSTate() {
    _velocityY = 0;
    position = Vector2(0, 0);
  }

  void updateState(
    double positionX,
    double positionY,
    double velocityY,
  ) {
    assert(game.gameMode is MultiplayerGameMode && !isMe);
    _smoothUpdatingPositionEffect?.removeFromParent();
    add(_smoothUpdatingPositionEffect = MoveToEffect(
      Vector2(positionX, positionY),
      EffectController(
        duration: 0.01,
      ),
      onComplete: () {
        _smoothUpdatingPositionEffect?.removeFromParent();
        _smoothUpdatingPositionEffect = null;
      },
    ));
    _velocityY = velocityY;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    if (other is HiddenCoin) {
      game.increaseScore(x, y, _velocityY);
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver(x, y, _velocityY);
    }
  }
}
