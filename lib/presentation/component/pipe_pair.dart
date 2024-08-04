import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/component/pipe.dart';

import 'hidden_coin.dart';

class PipePair extends PositionComponent
    with FlameBlocReader<GameCubit, GameState> {
  PipePair({
    required super.position,
    this.gap = 200.0,
    this.speed = 200.0,
  });

  final double gap;
  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll([
      Pipe(
        isFlipped: false,
        position: Vector2(0, gap / 2),
      ),
      Pipe(
        isFlipped: true,
        position: Vector2(0, -(gap / 2)),
      ),
      HiddenCoin(
        position: Vector2(30, 0),
      ),
    ]);
  }

  @override
  void update(double dt) {
    switch (bloc.state.currentPlayingState) {
      case PlayingState.paused:
      case PlayingState.gameOver:
      case PlayingState.idle:
        // We don't move it
        break;
      case PlayingState.playing:
        position.x -= speed * dt;
        break;
    }
    super.update(dt);
  }
}
