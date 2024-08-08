import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'hidden_coin.dart';

class OtherDash extends PositionComponent
    with HasGameRef<FlappyDashGame>, FlameBlocReader<GameCubit, GameState> {
  OtherDash({
    required this.playerId,
  }) : super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: 10,
        );

  final String playerId;
  late Sprite _dashSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _dashSprite = await Sprite.load('dash.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    bloc.state.
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSprite.render(
      canvas,
      size: size,
    );
  }
}
