import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/component/hidden_coin.dart';
import 'package:flappy_dash/presentation/component/fx/feather_burst.dart';
import 'package:flappy_dash/presentation/component/fx/jump_puff.dart';
import 'package:flappy_dash/presentation/component/outlined_text_component.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flutter/material.dart';

import 'auto_jump_dash.dart';
import 'character/dash_character.dart';
import 'dash_juice.dart';

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
       character = DashCharacter(DashType.fromUserId(playerId)),
       super(
         position: Vector2(0, 0),
         size: Vector2.all(80.0),
         anchor: Anchor.center,
       );

  final String playerId;
  final String displayName;
  final bool isMe;
  final DashType type;

  /// The drawing and the emotions of this dash.
  final DashCharacter character;
  OutlinedTextComponent? _nameComponent;

  /// Cosmetic body motion (tilt, squash and stretch, death tumble).
  final DashJuice juice = DashJuice();

  Color get color => AppColors.getDashColor(type);

  // Remote dashes only get positions, so their velocity for the tilt is
  // measured from how they move.
  double _visualVelocityY = 0;
  double? _lastY;

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
    final playingState = currentPlayingState;
    _updateJuice(dt);
    if (!_isNetworked && playingState.isPlaying) {
      _updatePositionNormally(dt);
      _checkIfDashIsOutOfBounds();
    }
    character.update(dt, y: position.y, state: playingState);
  }

  void _updateJuice(double dt) {
    final playingState = currentPlayingState;
    if (isMe) {
      _visualVelocityY = _velocityY;
    } else if (dt > 0) {
      final lastY = _lastY;
      if (lastY != null && playingState.isPlaying) {
        final measured = ((y - lastY) / dt).clamp(-900.0, 1400.0);
        // A sudden switch to climbing is a jump.
        if (measured < -250 && _visualVelocityY > -100) {
          onJumped();
        }
        _visualVelocityY += (measured - _visualVelocityY) * min(1, dt * 20);
      } else {
        _visualVelocityY = 0;
      }
      _lastY = y;
      if (playingState.isGameOver && _previousState == PlayingState.playing) {
        onDied();
      }
    }
    if (_previousState == PlayingState.gameOver &&
        playingState.isNotGameOver &&
        juice.isDead) {
      onRespawned();
    }
    _previousState = playingState;
    juice.idle = playingState.isIdle;
    juice.update(dt, _visualVelocityY);
  }

  PlayingState? _previousState;

  /// Cosmetic hooks (no effect on the simulation).
  void onJumped() {
    juice.onJump();
    final parent = this.parent;
    if (parent != null && isMounted) {
      parent.add(JumpPuff(position: position.clone(), priority: priority - 1));
    }
  }

  void onScored() => juice.onScore();

  void onDied() {
    if (juice.isDead) {
      return;
    }
    juice.onDie();
    if (!isMe) {
      isNameVisible = false;
    }
    final parent = this.parent;
    if (parent != null && isMounted) {
      parent.add(
        FeatherBurst(
          position: position.clone(),
          color: color,
          count: isMe ? 20 : 12,
          scaleFactor: isMe ? 1 : 0.8,
          priority: priority + 1,
        ),
      );
    }
  }

  void onRespawned() {
    juice.onRespawn();
    if (!isMe) {
      isNameVisible = true;
    }
  }

  /// Multiplayer: where the simulation says the dash is.
  void setNetworkedState(double x, double y, double velocityY) {
    // Our own predicted dash: a jump shows up as the velocity switching to
    // the jump force.
    if (isMe && velocityY < _velocityY - 300 && velocityY < 0) {
      onJumped();
    }
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
    onJumped();
  }

  @override
  void renderTree(Canvas canvas) {
    final playingState = currentPlayingState;
    if (!isMe &&
        playingState.isNotPlaying &&
        playingState.isNotIdle &&
        !juice.isTumbling) {
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
    juice.renderBody(canvas, size, _renderBody);
  }

  void _renderBody(Canvas canvas) => character.render(canvas, size.x, size.y);

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
      character.onScored();
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver(x, y, _velocityY);
      _autoJumpDash?.onDashDied();
    }
  }
}
