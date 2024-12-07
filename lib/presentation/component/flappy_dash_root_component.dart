import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/dash/dash.dart';
import 'package:flappy_dash/presentation/component/multiplayer_controller.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'pipe_pair.dart';

class FlappyDashRootComponent extends Component
    with HasGameRef<FlappyDashGame> {
  late Dash _dash;
  late PipePair _lastPipe;

  // late DashParallaxBackground _background;
  late final GameConfigEntity _config;

  late final MultiplayerCubit _cubit;

  int _pipeCounter = 0;

  String get myId => game.leaderboardCubit.state.currentAccount!.user.id;

  late MultiplayerCubit multiplayerCubit;
  StreamSubscription? _multiplayerCubitSubscription;
  MultiplayerState? _latestMultiplayerState;

  // We use it for temporary debugging
  static double gameSpeedMultiplier = 1.0;

  double get pipesDistance => switch (_config) {
        SinglePlayerGameConfigEntity() => _config.pipesDistance,
        MultiplayerGameConfigEntity() =>
          game.multiplayerCubit.state.matchState!.pipesDistance,
      };

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _config = game.gameMode.gameConfig;
    _cubit = game.multiplayerCubit;
    add(_dash = Dash(
      playerId: myId,
      displayName: '',
      isMe: true,
      priority: 10,
      autoJump: game.multiplayerCubit.state.isCurrentPlayerAutoJump,
    ));
    if (game.gameMode == const MultiplayerGameMode()) {
      multiplayerCubit = game.multiplayerCubit;
      _multiplayerCubitSubscription = multiplayerCubit.stream.listen(
        _onMultiplayerStateChange,
      );
      add(MultiplayerController(
        priority: 9,
        myDash: _dash,
      ));
    }
  }

  @override
  void onMount() {
    super.onMount();
    _restartGameForNewIdle(isFirstTime: true);
    game.camera.follow(
      _dash,
      horizontalOnly: true,
    );
  }

  void _onMultiplayerStateChange(MultiplayerState state) {
    final restarted = state.currentPlayingState.isIdle &&
        _latestMultiplayerState?.currentPlayingState == PlayingState.gameOver;
    if (restarted) {
      _restartGameForNewIdle(isFirstTime: false);
      // Auto start for auto jump
      if (state.isCurrentPlayerAutoJump) {
        onSpaceDown();
      }
    }

    _latestMultiplayerState = state;
  }

  void _restartGameForNewIdle({required bool isFirstTime}) {
    print('Restarting game for new idle');
    // Set a new position for the dash (zero for now)
    switch (game.gameMode) {
      case SinglePlayerGameMode():
        _dash.x = 0.0;
        _dash.y = 0.0;
        break;
      case MultiplayerGameMode():
        final cubit = game.multiplayerCubit;
        final state = cubit.state;
        _dash.x = state.matchState!.players[myId]!.x;
        _dash.y = state.matchState!.players[myId]!.y;
        break;
    }
    // Todo: _dash.resetVelocity();

    // Remove all pipes
    children.whereType<PipePair>().forEach((pipe) {
      pipe.removeFromParent();
    });

    // Generate new pipes
    _pipeCounter = _dash.x ~/ pipesDistance;
    _generatePipes(
      fromX: _dash.x + pipesDistance,
    );

    if (game.gameMode is MultiplayerGameMode) {
      multiplayerCubit.addDebugMessage(
        DebugFunctionCallEvent(
          'FlappyDashRootComponent',
          '_restartGameForNewIdle',
          {
            'isFirstTime': isFirstTime.toString(),
            'x': _dash.x.toString(),
            'y': _dash.y.toString(),
          },
        ),
      );
    }
  }

  double _getNewPipeYForMultiplayer(MultiplayerGameConfigEntity config) {
    final matchState = _cubit.state.matchState!;
    final pipesPosition = matchState.pipesNormalizedYPositions;
    final posIndex = _pipeCounter % pipesPosition.length;
    return (pipesPosition[posIndex] * matchState.pipesYRange).toDouble();
  }

  void _generatePipes({
    int count = 1,
    required double fromX,
  }) {
    _cubit.addDebugMessage(DebugFunctionCallEvent(
      'FlappyDashRootComponent',
      '_generatePipes',
      {
        'count': count.toString(),
        'fromX': fromX.toString(),
      },
    ));

    final y = switch (_config) {
      SinglePlayerGameConfigEntity() =>
      (Random().nextDouble() * _cubit.state.matchState!.pipesYRange) -
          (_cubit.state.matchState!.pipesYRange / 2),
      MultiplayerGameConfigEntity() => _getNewPipeYForMultiplayer(_config),
    };

    final pipesDistance = switch(_config) {
      SinglePlayerGameConfigEntity() => _config.pipesDistance,
      MultiplayerGameConfigEntity() => _cubit.state.matchState!.pipesDistance,
    };

    final pipeHoleGap = switch(_config) {
      SinglePlayerGameConfigEntity() => _config.pipeHoleGap,
      MultiplayerGameConfigEntity() => _cubit.state.matchState!.pipesHoleGap,
    };

    final pipeWidth = switch(_config) {
      SinglePlayerGameConfigEntity() => _config.pipeWidth,
      MultiplayerGameConfigEntity() => _cubit.state.matchState!.pipeWidth,
    };

    for (int i = 0; i < count; i++) {
      add(_lastPipe = PipePair(
        position: Vector2(fromX + (i * pipesDistance), y),
        gap: pipeHoleGap,
        pipeWidth: pipeWidth,
        priority: 3,
      ));
      _pipeCounter++;
    }
  }

  @override
  void updateTree(double dt) {
    super.updateTree(dt * gameSpeedMultiplier);
  }

  void _removeLastPipes() {
    final pipes = children.whereType<PipePair>();
    final shouldBeRemoved = max(pipes.length - 5, 0);
    pipes.take(shouldBeRemoved).forEach((pipe) {
      pipe.removeFromParent();
    });
  }

  void onSpaceDown() => _jump();

  void onTapDown(TapDownEvent event) => _jump();

  void _jump() {
    _checkToStart();
    if (game.getCurrentPlayingState().isNotPlaying) {
      return;
    }
    game.playerJumped();
    _dash.jump();
  }

  void _checkToStart() {
    if (game.getCurrentPlayingState().isIdle) {
      game.onGameStarted();
    }
  }

  PipePair _removeAllPipesExceptLastOne() {
    final pipes = children.whereType<PipePair>();
    for (int i = pipes.length - 2; i >= 0; i--) {
      pipes.elementAt(i).removeFromParent();
    }
    return pipes.last;
  }

  void _tryToLoopTheGame() {
    if (_config is! MultiplayerGameConfigEntity) {
      return;
    }

    // We loop if the dash is out of the screen
    if (_dash.x <= game.worldWidth) {
      return;
    }

    final lastPipe = _removeAllPipesExceptLastOne();
    lastPipe.x = 0.0;
    _dash.x -= game.worldWidth;
    _pipeCounter = 0;
    _generatePipes(
      fromX: pipesDistance,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tryToLoopTheGame();
    if (_dash.x > _lastPipe.x) {
      _generatePipes(
        fromX: _lastPipe.x + pipesDistance,
      );
      _removeLastPipes();
    }
  }

  @override
  void onRemove() {
    _multiplayerCubitSubscription?.cancel();
    super.onRemove();
  }
}
