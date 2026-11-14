import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash_parallax_background.dart';
import 'package:flappy_dash/presentation/component/fx/score_burst.dart';
import 'package:flappy_dash/presentation/juice/game_shaders.dart';
import 'package:flappy_dash/presentation/juice/screen_fx.dart';
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
        camera: CameraComponent.withFixedResolution(width: 600, height: 1000),
      );

  final Random random = Random();
  final GameMode gameMode;
  final SingleplayerGameCubit singleplayerCubit;
  final MultiplayerCubit multiplayerCubit;
  final LeaderboardCubit leaderboardCubit;

  /// Screen shake and the death shockwave (cosmetic only).
  final ScreenFx screenFx = ScreenFx();

  @override
  Future<void> onLoad() async {
    await GameShaders.load();
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    screenFx.update(dt);
  }

  int _warmUpFrames = 2;

  @override
  void renderTree(Canvas canvas) {
    screenFx.render(canvas, size, super.renderTree);
    if (_warmUpFrames > 0) {
      _warmUpFrames--;
      GameShaders.warmUp(canvas);
    }
  }

  PlayingState getCurrentPlayingState({String? otherPlayerId}) =>
      switch (gameMode) {
        SinglePlayerGameMode() => singleplayerCubit.state.currentPlayingState,
        MultiplayerGameMode() =>
          otherPlayerId != null
              ? multiplayerCubit
                    .state
                    .matchState!
                    .players[otherPlayerId]!
                    .playingState
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
    print('FXMARK death');
    _playDeathEffects();
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
    print('FXMARK score');
    _playScoreEffects();
    switch (gameMode) {
      case SinglePlayerGameMode():
        singleplayerCubit.increaseScore();
        break;
      case MultiplayerGameMode():
        multiplayerCubit.increaseScore(x, y, velocityY);
        break;
    }
  }

  void _playDeathEffects() {
    final dash = world.rootComponent.myDash;
    if (dash.juice.isDead) {
      return;
    }
    dash.onDied();
    screenFx.shake(0.75);
    // A ring about two dashes wide around the dash, measured on screen.
    final screenPosition = camera.localToGlobal(dash.position);
    final screenEdge = camera.localToGlobal(dash.position + Vector2(170, 0));
    screenFx.shockwave(
      screenPosition.toOffset(),
      radius: (screenEdge - screenPosition).length,
    );
  }

  void _playScoreEffects() {
    final root = world.rootComponent;
    final dash = root.myDash;
    dash.onScored();
    root.add(
      ScoreBurst(
        position: dash.position + Vector2(10, 0),
        color: dash.color,
        priority: 11,
      ),
    );
    root.wobblePipeAt(dash.x);
    screenFx.shake(0.12);
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
    with TapCallbacks, HasGameReference<FlappyDashGame> {
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
