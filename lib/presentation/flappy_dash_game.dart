import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash_parallax_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bloc/singleplayer/singleplayer_game_cubit.dart';
import 'component/flappy_dash_root_component.dart';

class FlappyDashGame extends FlameGame<FlappyDashWorld>
    with KeyboardEvents, HasCollisionDetection {
  FlappyDashGame(
    this.gameMode,
    this.singleplayerCubit,
    this.multiplayerCubit,
    this.leaderboardCubit,
  ) : super(
          world: FlappyDashWorld(),
          camera: CameraComponent.withFixedResolution(
            width: 600,
            height: 1000,
          ),
        );

  final Random random = Random();
  final GameMode gameMode;
  final SingleplayerGameCubit singleplayerCubit;
  final MultiplayerCubit multiplayerCubit;
  final LeaderboardCubit leaderboardCubit;

  PlayingState getCurrentPlayingState({
    String? otherPlayerId,
  }) =>
      switch (gameMode) {
        SinglePlayerGameMode() => singleplayerCubit.state.currentPlayingState,
        MultiplayerGameMode() => otherPlayerId != null
            ? multiplayerCubit
                .state.matchState!.players[otherPlayerId]!.playingState
            : multiplayerCubit.state.currentPlayingState,
      };

  double get worldWidth =>
      gameMode.gameConfig.pipesDistance *
      multiplayerCubit.state.matchState!.pipesPositions.length;

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

  void gameOver(double x, double y, double velocityY) async {
    switch (gameMode) {
      case SinglePlayerGameMode():
        await singleplayerCubit.gameOver();
        leaderboardCubit.refreshLeaderboard();
        break;
      case MultiplayerGameMode():
        multiplayerCubit.playerDied(x, y, velocityY);
        break;
    }
  }

  void increaseScore(double x, double y, double velocityY) {
    switch (gameMode) {
      case SinglePlayerGameMode():
        singleplayerCubit.increaseScore();
        break;
      case MultiplayerGameMode():
        multiplayerCubit.increaseScore(x, y, velocityY);
        break;
    }
  }

  void onGameStarted() {
    switch (gameMode) {
      case SinglePlayerGameMode():
        singleplayerCubit.startPlaying();
        break;
      case MultiplayerGameMode():
        multiplayerCubit.startPlaying();
        break;
    }
  }

  void playerJumped(double x, double y, double velocityY) {
    switch(gameMode) {
      case SinglePlayerGameMode():
        // Does nothing
        break;
      case MultiplayerGameMode():
        multiplayerCubit.dispatchJumpEvent(x, y, velocityY);
        break;
    }
  }

  @override
  void onRemove() {
    removeAll(children);
    processLifecycleEvents();
    super.onRemove();
  }

  void onGameFinished() {
    removeAll(children);
    removeFromParent();
    processLifecycleEvents();
  }
}

class FlappyDashWorld extends World
    with TapCallbacks, HasGameRef<FlappyDashGame> {
  late FlappyDashRootComponent _rootComponent;

  FlappyDashRootComponent get rootComponent => _rootComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(_rootComponent = FlappyDashRootComponent());
    game.camera.backdrop = DashParallaxBackground();
  }

  void onSpaceDown() => _rootComponent.onSpaceDown();

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _rootComponent.onTapDown(event);
  }
}
