import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
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
    required this.speed,
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

  double _velocityY = 0;

  double get velocityY => _velocityY;

  double get gravity => gameRef.world.rootComponent.gravity;

  double get jumpForce => _jumpForce;

  final double _jumpForce = -500;
  final double speed;

  late double _multiplayerCorrectPositionAfter;

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
    _resetCorrectPositionAfter();

    if (autoJump) {
      add(_autoJumpDash = AutoJumpDash());
    }
  }

  void _resetCorrectPositionAfter() {
    if (game.gameMode is! MultiplayerGameMode) {
      return;
    }
    _multiplayerCorrectPositionAfter =
        (game.gameMode as MultiplayerGameMode).gameConfig.correctPositionEvery *
            FlappyDashRootComponent.gameSpeedMultiplier;
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
    _velocityY += gravity * dt;
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
    if (game.gameMode is! MultiplayerGameMode) {
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

  void resetVelocity() {
    _velocityY = 0;
  }

  void updateState(double positionX, double positionY, double velocityY,
      {double duration = 0.15}) {
    assert(game.gameMode is MultiplayerGameMode && !isMe);
    final xDiff = (positionX - x).abs();
    if (xDiff > 200 || duration == 0) {
      x = positionX;
      y = positionY;
      _velocityY = velocityY;
    } else {
      final scaledDuration =
          duration * FlappyDashRootComponent.gameSpeedMultiplier;
      final newX = positionX + (speed * scaledDuration);
      final newVelocity = velocityY + gravity * scaledDuration;
      final newY = positionY + (newVelocity * scaledDuration);
      _smoothUpdatingPositionEffect?.removeFromParent();
      add(
        _smoothUpdatingPositionEffect = UpdateDashStateEffect(
          EffectController(
            duration: scaledDuration,
          ),
          positionX: newX,
          positionY: newY,
          velocityY: newVelocity,
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
      game.increaseScore(x, y, _velocityY);
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver(x, y, _velocityY);
      _autoJumpDash?.onDashDied();
    }
  }
}

class UpdateDashStateEffect extends ComponentEffect<Dash> {
  UpdateDashStateEffect(
    super.controller, {
    required this.positionX,
    required this.positionY,
    required this.velocityY,
    super.onComplete,
  });

  final double positionX;
  final double positionY;
  final double velocityY;

  late final double initialX;
  late final double initialY;
  late final double initialVelocityY;

  @override
  void onMount() {
    super.onMount();
    initialX = target.x;
    initialY = target.y;
    initialVelocityY = target.velocityY;
  }

  @override
  void apply(double progress) {
    final newX = lerpDouble(initialX, positionX, progress)!;
    final newY = lerpDouble(initialY, positionY, progress)!;
    final newVelocityY = lerpDouble(initialVelocityY, velocityY, progress)!;
    target.updateState(newX, newY, newVelocityY, duration: 0);
  }
}
