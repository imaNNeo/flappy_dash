import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bloc/game/game_cubit.dart';
import 'bloc/multiplayer/multiplayer_cubit.dart';
import 'component/flappy_dash_root_component.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld>
    with KeyboardEvents, HasCollisionDetection {
  FlappyDashGame(
    this.gameCubit,
    this.multiplayerCubit,
    this.leaderboardCubit,
  ) : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 600,
            height: 1000,
          ),
        );

  final GameCubit gameCubit;
  final MultiplayerCubit multiplayerCubit;
  final LeaderboardCubit leaderboardCubit;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      world.onSpaceDown();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void gameOver(double x, double y) async {
    await gameCubit.gameOver();
    switch(gameCubit.state.gameMode!) {
      case SinglePlayerGameMode():
        leaderboardCubit.refreshLeaderboard();
        break;
      case MultiplayerGameMode():
        multiplayerCubit.dispatchPlayerDiedEvent(x, y);
        break;
    }
  }

  void increaseScore(double x, double y) {
    gameCubit.increaseScore();
    if (gameCubit.state.gameMode is MultiplayerGameMode) {
      multiplayerCubit.dispatchIncreaseScoreEvent(x, y);
    }
  }
}

class FlappyDashWorld extends World
    with TapCallbacks, HasGameRef<FlappyDashGame> {
  late FlappyDashRootComponent _rootComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(FlameMultiBlocProvider(
      providers: [
        FlameBlocProvider<GameCubit, GameState>(
          create: () => game.gameCubit,
        ),
        FlameBlocProvider<MultiplayerCubit, MultiplayerState>(
          create: () => game.multiplayerCubit,
        ),
        FlameBlocProvider<LeaderboardCubit, LeaderboardState>(
          create: () => game.leaderboardCubit,
        ),
      ],
      children: [
        _rootComponent = FlappyDashRootComponent(),
      ],
    ));
  }

  void onSpaceDown() => _rootComponent.onSpaceDown();

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _rootComponent.onTapDown(event);
  }
}
