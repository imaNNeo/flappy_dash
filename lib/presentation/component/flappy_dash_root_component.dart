import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flappy_dash/domain/entities/debug/debug_message.dart';
import 'package:flappy_dash/domain/entities/game_config_entity.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/netcode/dash_physics.dart';
import 'package:flappy_dash/domain/netcode/dash_predictor.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/component/multiplayer_controller.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

import 'dash/dash.dart';
import 'pipe_pair.dart';

class FlappyDashRootComponent extends Component
    with HasGameReference<FlappyDashGame> {
  late Dash _dash;
  late PipePair _lastPipe;

  late final GameConfigEntity _config;

  String get myId => game.leaderboardCubit.state.currentAccount!.user.id;

  late MultiplayerCubit multiplayerCubit;
  StreamSubscription? _multiplayerCubitSubscription;
  StreamSubscription? _matchEventsSubscription;
  MultiplayerState? _latestMultiplayerState;

  // We use it for temporary debugging
  static double gameSpeedMultiplier = 1.0;

  double get gravity => 1400.0;

  bool get _isMultiplayer => game.gameMode is MultiplayerGameMode;

  // --- Multiplayer only ---
  // Our dash is simulated in fixed ticks (the same ones the server runs) and
  // predicted locally; see DashPredictor.
  DashPredictor? _predictor;
  double _tickAccumulator = 0;
  bool _jumpPending = false;

  /// The pipes on screen, by pipe index (pipe k stands at k * pipesDistance).
  final Map<int, PipePair> _pipesByIndex = {};

  /// Pipes before this index are not shown (the one we spawn on and the
  /// ones behind it), like the server ignores them.
  int _firstVisiblePipe = 0;

  DashPredictor? get predictor => _predictor;

  /// Our dash's x in the unwrapped world (see dash_physics.dart).
  double get myDashX => _dash.x;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (_isMultiplayer) {
      multiplayerCubit = game.multiplayerCubit;
      _multiplayerCubitSubscription = multiplayerCubit.stream.listen(
        _onMultiplayerStateChange,
      );
      _predictor = DashPredictor(
        multiplayerCubit.state.matchState!.pipesPositions,
      );
      _matchEventsSubscription = multiplayerCubit.matchEvents.listen(
        _onMatchEvent,
      );
      add(MultiplayerController(priority: 9));
    }
    _config = game.gameMode.gameConfig;
    add(
      _dash = Dash(
        playerId: myId,
        displayName: '',
        isMe: true,
        priority: 10,
        speed: _config.dashMoveSpeed,
        autoJump: game.multiplayerCubit.state.isCurrentPlayerAutoJump,
      ),
    );

    _restartGameForNewIdle(isFirstTime: true);
    game.camera.follow(_dash, horizontalOnly: true);
  }

  void _onMultiplayerStateChange(MultiplayerState state) {
    final restarted =
        state.currentPlayingState.isIdle &&
        _latestMultiplayerState?.currentPlayingState == PlayingState.gameOver;
    if (restarted) {
      _restartGameForNewIdle(isFirstTime: false);
      // Auto start for auto jump
      if (state.isCurrentPlayerAutoJump) {
        onSpaceDown();
      }
    }

    // Playing without a life: the cubit started us (auto jump does that when
    // the game page opens).
    if (state.currentPlayingState.isPlaying && !_predictor!.hasLife) {
      _startMyLife();
    }

    _latestMultiplayerState = state;
  }

  void _startMyLife() {
    final me = multiplayerCubit.state.matchState!.players[myId]!;
    _predictor!.startLife(me.lastKnownX, me.lastKnownY, me.score);
    _tickAccumulator = 0;
    multiplayerCubit.correctScore(me.score);
  }

  void _onMatchEvent(MatchEvent event) {
    if (event is! MatchSnapshotEvent) {
      return;
    }
    final roster = multiplayerCubit.state.matchState?.roster;
    final predictor = _predictor;
    if (roster == null || predictor == null) {
      return;
    }
    final myIndex = roster.indexOf(myId);
    if (myIndex < 0) {
      return;
    }
    for (final entry in event.snapshot.entries) {
      if (entry.rosterIndex != myIndex) {
        continue;
      }
      final serverSaysDied = predictor.reconcile(entry);
      final sim = predictor.sim;
      if (sim != null && predictor.lifeStartSeq >= 0) {
        multiplayerCubit.correctScore(sim.score);
      }
      if (serverSaysDied && game.getCurrentPlayingState().isPlaying) {
        _onMyDashDied();
      }
    }
  }

  void _restartGameForNewIdle({required bool isFirstTime}) {
    switch (game.gameMode) {
      case SinglePlayerGameMode():
        _dash.x = 0.0;
        _dash.y = 0.0;
        _dash.resetVelocity();
        break;
      case MultiplayerGameMode():
        // The server picks where we (re)spawn.
        final me = multiplayerCubit.state.matchState!.players[myId]!;
        _predictor!.endLife();
        _tickAccumulator = 0;
        _jumpPending = false;
        _dash.setNetworkedState(me.lastKnownX, me.lastKnownY, 0);
        _firstVisiblePipe = DashPhysics.pipeIndexAt(me.lastKnownX) + 1;
        for (final pipe in _pipesByIndex.values) {
          pipe.removeFromParent();
        }
        _pipesByIndex.clear();
        _updateMultiplayerPipes();
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
        return;
    }

    // Remove all pipes
    children.whereType<PipePair>().forEach((pipe) {
      pipe.removeFromParent();
    });

    // Generate new pipes
    _generatePipes(fromX: _dash.x + _config.pipesDistance);
  }

  void _generatePipes({int count = 1, required double fromX}) {
    for (int i = 0; i < count; i++) {
      final area = _config.pipesPositionArea;
      final y = (Random().nextDouble() * area) - (area / 2);
      add(
        _lastPipe = PipePair(
          position: Vector2(fromX + (i * _config.pipesDistance), y),
          gap: _config.pipeHoleGap,
          pipeWidth: _config.pipeWidth,
          priority: 3,
        ),
      );
    }
  }

  /// Multiplayer: keeps the pipes around our dash on screen. Pipe k is at
  /// x = k * pipesDistance in the unwrapped world.
  void _updateMultiplayerPipes() {
    const d = DashPhysics.pipesDistance;
    // The camera shows 600 units around the dash; keep a margin.
    final from = max(((_dash.x - 500) / d).floor(), _firstVisiblePipe);
    final to = ((_dash.x + 700) / d).ceil();
    _pipesByIndex.removeWhere((index, pipe) {
      if (index < from || index > to) {
        pipe.removeFromParent();
        return true;
      }
      return false;
    });
    final pipesPositions = multiplayerCubit.state.matchState!.pipesPositions;
    for (var k = from; k <= to; k++) {
      if (_pipesByIndex.containsKey(k)) {
        continue;
      }
      final pipe = PipePair(
        position: Vector2(k * d, DashPhysics.pipeGapCenterY(pipesPositions, k)),
        gap: DashPhysics.pipeHoleGap,
        pipeWidth: DashPhysics.pipeWidth,
        priority: 3,
      );
      _pipesByIndex[k] = pipe;
      add(pipe);
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
    if (_isMultiplayer) {
      // Applied in the next simulation tick.
      _jumpPending = true;
      return;
    }
    _dash.jump();
  }

  void _checkToStart() {
    if (game.getCurrentPlayingState().isIdle) {
      if (_isMultiplayer) {
        _startMyLife();
      }
      game.onGameStarted();
    }
  }

  void _onMyDashDied() {
    game.gameOver(_dash.x, _dash.y, _dash.velocityY);
    _dash.onDiedInSimulation();
  }

  /// Runs our dash's fixed ticks for this frame and sends our inputs.
  void _updateMultiplayer(double dt) {
    final predictor = _predictor!;
    predictor.smoothError(dt);
    if (predictor.hasLife) {
      _tickAccumulator += dt;
      // Don't try to catch up more than a quarter second (e.g. after a hitch).
      _tickAccumulator = min(_tickAccumulator, 0.25);
      while (_tickAccumulator >= DashPhysics.dt) {
        _tickAccumulator -= DashPhysics.dt;
        final jump = _jumpPending && predictor.isAlive;
        _jumpPending = false;
        final result = predictor.tick(jump);
        switch (result) {
          case DashStepResult.scored:
            game.increaseScore(_dash.x, _dash.y, _dash.velocityY);
            _dash.character.onScored();
            break;
          case DashStepResult.died:
            _onMyDashDied();
            break;
          case DashStepResult.none:
            break;
        }
        final packet = predictor.pollInputPacket();
        if (packet != null) {
          multiplayerCubit.sendInput(packet);
        }
      }
      final render = predictor.renderState(_tickAccumulator / DashPhysics.dt);
      if (render != null) {
        _dash.setNetworkedState(render.x, render.y, render.vy);
      }
    }
    _updateMultiplayerPipes();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isMultiplayer) {
      _updateMultiplayer(dt);
      return;
    }
    if (_dash.x > _lastPipe.x) {
      _generatePipes(fromX: _lastPipe.x + _config.pipesDistance);
      _removeLastPipes();
    }
  }

  @override
  void onRemove() {
    _multiplayerCubitSubscription?.cancel();
    _matchEventsSubscription?.cancel();
    super.onRemove();
  }
}
