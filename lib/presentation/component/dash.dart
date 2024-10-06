import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';

import 'hidden_coin.dart';

class Dash extends PositionComponent
    with
        CollisionCallbacks,
        HasGameRef<FlappyDashGame>,
        FlameBlocReader<GameCubit, GameState> {
  Dash({
    this.speed = 200.0,
    required this.playerId,
    required this.isMe,
  }) : super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: 10,
        );

  final String playerId;
  final bool isMe;
  late final MultiplayerCubit _multiplayerCubit;

  late Sprite _dashSprite;
  final double _gravity = 1400.0;
  double _yVelocity = 0;
  final double _jumpForce = -500;
  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _dashSprite = await Sprite.load('dash.png');
    final radius = size.x / 2;
    final center = size / 2;
    add(CircleHitbox(
      radius: radius * 0.75,
      position: center * 1.1,
      anchor: Anchor.center,
    ));
    _multiplayerCubit = game.multiplayerCubit;
  }

  PlayingState get currentPlayingState => isMe
      ? bloc.state.currentPlayingState
      : _multiplayerCubit.state.matchState!.players[playerId]!.playingState;

  @override
  void update(double dt) {
    super.update(dt);
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _yVelocity += _gravity * dt;
    position.y += _yVelocity * dt;
    position.x += speed * dt;
  }

  void jump() {
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    _yVelocity = _jumpForce;
    _multiplayerCubit.dispatchJumpEvent(x);
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
    if (currentPlayingState.isNotPlaying) {
      return;
    }
    if (other is HiddenCoin) {
      game.increaseScore();
      _multiplayerCubit.dispatchIncreaseScoreEvent(x);
      other.removeFromParent();
    } else if (other is Pipe) {
      game.gameOver();
      _multiplayerCubit.dispatchPlayerDiedEvent(x);
    }
  }
}
