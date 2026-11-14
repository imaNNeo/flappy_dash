import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/component/hidden_coin.dart';
import 'package:flappy_dash/presentation/component/outlined_text_component.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

import 'auto_jump_dash.dart';

class Dash extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlappyDashGame> {
  Dash({
    required this.speed,
    required this.playerId,
    required this.displayName,
    required this.isMe,
    this.autoJump = false,
    super.priority,
  }) : type = DashType.fromUserId(playerId),
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

  double get gravity => game.world.rootComponent.gravity;

  double get jumpForce => _jumpForce;

  final double _jumpForce = -500;
  final double speed;

  /// In multiplayer the dash doesn't move on its own: our own dash follows
  /// the DashPredictor, the others follow their RemoteDashInterpolator.
  bool get _isNetworked => game.gameMode is MultiplayerGameMode;

  /// The state of another player's dash at the moment we're drawing it
  /// (interpolated, so a bit behind the match state).
  PlayingState? remotePlayingState;

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
    // Collisions in multiplayer are part of the shared simulation
    // (dash_physics.dart), not Flame's collision detection.
    if (isMe && !_isNetworked) {
      add(
        CircleHitbox(
          radius: radius * 0.75,
          position: center * 1.1,
          anchor: Anchor.center,
          collisionType: CollisionType.active,
        ),
      );
    }
    if (isMe && autoJump) {
      add(_autoJumpDash = AutoJumpDash());
    }
    add(
      _nameComponent = OutlinedTextComponent(
        text: _isNameVisible ? displayName : '',
        position: Vector2(size.x / 2, 0),
        textStyle: TextStyle(
          fontSize: 24,
          fontFamily: 'Chewy',
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: AppColors.getDashColor(type),
        ),
      ),
    );
  }

  PlayingState get currentPlayingState => isMe
      ? game.getCurrentPlayingState()
      : remotePlayingState ??
            game.getCurrentPlayingState(otherPlayerId: playerId);

  @override
  void update(double dt) {
    super.update(dt);
    if (_isNetworked || currentPlayingState.isNotPlaying) {
      return;
    }
    _updatePositionNormally(dt);
    _checkIfDashIsOutOfBounds();
  }

  /// Multiplayer: where the simulation says the dash is.
  void setNetworkedState(double x, double y, double velocityY) {
    position.setValues(x, y);
    _velocityY = velocityY;
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

  void jump() {
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _velocityY = _jumpForce;
  }

  @override
  void renderTree(Canvas canvas) {
    final playingState = currentPlayingState;
    if (!isMe && playingState.isNotPlaying && playingState.isNotIdle) {
      return;
    }
    if (!visibleOnIdle && playingState.isIdle) {
      return;
    }
    // In multiplayer, other dashes are placed on the copy of the looping
    // world nearest to ours (MultiplayerController), so no mirroring needed.
    super.renderTree(canvas);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSprite.render(canvas, size: size);
  }

  /// Multiplayer: the simulation says we died (there are no collision
  /// callbacks there).
  void onDiedInSimulation() => _autoJumpDash?.onDashDied();

  void resetVelocity() {
    _velocityY = 0;
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
