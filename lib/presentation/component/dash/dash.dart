import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/component/flappy_dash_root_component.dart';
import 'package:flappy_dash/presentation/component/hidden_coin.dart';
import 'package:flappy_dash/presentation/component/outlined_text_component.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

import 'auto_jump_dash.dart';

class Dash extends PositionComponent
    with CollisionCallbacks, HasGameRef<FlappyDashGame> {
  Dash({
    required this.playerId,
    required this.displayName,
    required this.isMe,
    this.autoJump = false,
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
  late final Sprite _dashSprite;
  OutlinedTextComponent? _nameComponent;

  double get velocityY => _velocityY;

  double _velocityY = 0;
  double _velocityX = 0;

  double get gravityY {
    final GameConfigEntity gameConfig = game.gameMode.gameConfig;
    return switch (gameConfig) {
      SinglePlayerGameConfigEntity() => gameConfig.gravityY,
      MultiplayerGameConfigEntity() =>
        gameRef.multiplayerCubit.state.matchState!.gravityY.toDouble(),
    };
  }

  double get jumpForce {
    final config = game.gameMode.gameConfig;
    return switch (config) {
      SinglePlayerGameConfigEntity() => config.jumpForce,
      MultiplayerGameConfigEntity() => gameRef
          .multiplayerCubit.state.matchState!.players[playerId]!.jumpForce
          .toDouble()
    };
  }

  UpdateDashStateEffect? _smoothUpdatingPositionEffect;

  bool _isNameVisible = true;

  bool get isNameVisible => _isNameVisible;

  final bool autoJump;

  AutoJumpDash? _autoJumpDash;

  set isNameVisible(bool value) {
    _isNameVisible = value;
    if (value) {
      _nameComponent?.text = displayName;
    } else {
      _nameComponent?.text = '';
    }
  }

  late bool visibleOnIdle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    visibleOnIdle = isMe;
    _dashSprite = await game.loadSprite(type.flamePngAssetName);
    final radius = size.x / 2;
    final center = size / 2;
    if (isMe) {
      add(CircleHitbox(
        radius: radius * 0.75,
        position: center * 1.1,
        anchor: Anchor.center,
        collisionType: isMe ? CollisionType.active : CollisionType.inactive,
      ));
      if (autoJump) {
        add(_autoJumpDash = AutoJumpDash());
      }
    }
    add(_nameComponent = OutlinedTextComponent(
      text: _isNameVisible ? displayName : '',
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
    if (isMe) {
      _tryToUpdatePositionNormally(dt);
      _checkIfDashIsOutOfBounds();
    }
  }

  void _tryToUpdatePositionNormally(double dt) {
    final config = game.gameMode.gameConfig;
    _velocityX = switch (config) {
      SinglePlayerGameConfigEntity() => config.dashMoveSpeed,
      MultiplayerGameConfigEntity() =>
        gameRef.multiplayerCubit.state.localPlayerState!.velocityX,
    };
    _velocityY += gravityY * dt;
    position.y += _velocityY * dt;
    position.x += _velocityX * dt;
  }

  void _checkIfDashIsOutOfBounds() {
    if (!isMe) {
      return;
    }
    if (position.y.abs() > (game.size.y / 2) + 20) {
      game.gameOver();
    }
  }

  @override
  void renderTree(Canvas canvas) {
    if (!isMe &&
        currentPlayingState.isNotPlaying &&
        currentPlayingState.isNotIdle) {
      return;
    }
    if (!visibleOnIdle && currentPlayingState.isIdle) {
      return;
    }
    super.renderTree(canvas);
    if (game.gameMode is MultiplayerGameMode && !isMe) {
      final worldWidth = game.worldWidth;
      final visibleWidth = game.camera.visibleWorldRect.size.width;
      if (x < visibleWidth) {
        // mirror for the right side
        canvas.save();
        canvas.translate(game.worldWidth, 0);
        super.renderTree(canvas);
        canvas.restore();
      } else if (x > worldWidth - visibleWidth) {
        // mirror for the left side
        canvas.save();
        canvas.translate(-game.worldWidth, 0);
        super.renderTree(canvas);
        canvas.restore();
      }
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

  void updateState(double newX, double newY, {required double duration}) {
    final xDiff = (newX - x).abs();
    if (xDiff > 200 || duration == 0) {
      x = newX;
      y = newY;
    } else {
      final scaledDuration =
          duration * FlappyDashRootComponent.gameSpeedMultiplier;
      _smoothUpdatingPositionEffect?.removeFromParent();
      add(
        _smoothUpdatingPositionEffect = UpdateDashStateEffect(
          EffectController(
            duration: scaledDuration,
          ),
          positionX: newX,
          positionY: newY,
          onComplete: () {
            _smoothUpdatingPositionEffect?.removeFromParent();
            _smoothUpdatingPositionEffect = null;
          },
        ),
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    if (other is HiddenCoin) {
      game.increaseScore();
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver();
      _autoJumpDash?.onDashDied();
    }
  }

  void jump() {
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _velocityY = jumpForce;
  }
}

class UpdateDashStateEffect extends ComponentEffect<Dash> {
  UpdateDashStateEffect(
    super.controller, {
    required this.positionX,
    required this.positionY,
    super.onComplete,
  });

  final double positionX;
  final double positionY;

  late final double initialX;
  late final double initialY;

  @override
  void onMount() {
    super.onMount();
    initialX = target.x;
    initialY = target.y;
  }

  @override
  void apply(double progress) {
    final newX = lerpDouble(initialX, positionX, progress)!;
    final newY = lerpDouble(initialY, positionY, progress)!;
    target.updateState(newX, newY, duration: 0);
  }
}
