import 'dart:math' as math;

import 'package:flappy_dash/domain/entities/playing_state.dart';

import 'dash_physics.dart';
import 'net_protocol.dart';

/// Client-side prediction and server reconciliation for the player's own dash
/// (https://developer.valvesoftware.com/wiki/Prediction).
///
/// The dash is simulated locally right away, one fixed tick at a time, with
/// the same code the server runs. Every tick has a number (seq). The jumps are
/// sent to the server as input commands; the server simulates them as the
/// authority and tells us in each snapshot the last tick it simulated and the
/// state it got. We then replay our not yet acknowledged jumps on top of that
/// state: if we land where we predicted (the usual case), nothing changes.
/// If not, we take the corrected state and hide the jump on screen by
/// smoothing the difference out over ~100ms.
class DashPredictor {
  DashPredictor(this.pipesPositions);

  final List<double> pipesPositions;

  /// Send a heartbeat (with no jumps) at least every this many ticks, so the
  /// server can simulate our dash without waiting (50ms, 20 per second).
  static const heartbeatEveryTicks = 3;

  /// Keep telling the server about a life that we think is over until it
  /// confirms it, but not forever.
  static const sendAfterDeathTicks = 2 * DashPhysics.tickRate;

  /// A difference smaller than this is f32 rounding, not a misprediction.
  static const _maxPredictionError = 0.05;

  /// Prediction errors are smoothed out over roughly this many seconds.
  static const errorSmoothingSeconds = 0.1;

  /// The last tick we simulated. Ticks only advance while a life runs.
  int seq = 0;

  /// The tick the current life started at, -1 before the first one.
  int lifeStartSeq = -1;

  DashSim? _sim;
  DashSim? _previousSim;

  /// Jumps of the current life the server hasn't acknowledged yet.
  final List<int> _unackedJumps = [];
  int _ackedSeq = 0;
  int _lastSentUpToSeq = -1;
  bool _jumpedSinceLastSend = false;
  int _diedAtSeq = -1;
  bool _serverConfirmedDeath = false;

  double _errorX = 0;
  double _errorY = 0;

  /// How many times the server corrected us (for the debug panel and tests).
  int corrections = 0;

  DashSim? get sim => _sim;

  bool get isAlive => _sim?.alive ?? false;

  bool get hasLife => lifeStartSeq >= 0 && _sim != null;

  int get ackedSeq => _ackedSeq;

  /// Starts a new life at a spawn point. Returns its first tick.
  int startLife(double spawnX, double spawnY, int score) {
    lifeStartSeq = seq + 1;
    _sim = DashSim.spawn(spawnX, spawnY, score);
    _previousSim = _sim!.copy();
    _unackedJumps.clear();
    _ackedSeq = lifeStartSeq - 1;
    _lastSentUpToSeq = lifeStartSeq - 1;
    _jumpedSinceLastSend = false;
    _diedAtSeq = -1;
    _serverConfirmedDeath = false;
    _errorX = 0;
    _errorY = 0;
    return lifeStartSeq;
  }

  /// Simulates one tick. [jump] is whether the player tapped since the
  /// previous tick.
  DashStepResult tick(bool jump) {
    final sim = _sim;
    if (sim == null) {
      return DashStepResult.none;
    }
    seq++;
    _previousSim = sim.copy();
    if (!sim.alive) {
      return DashStepResult.none;
    }
    if (jump) {
      _unackedJumps.add(seq);
      _jumpedSinceLastSend = true;
    }
    final result = DashPhysics.step(sim, jump, pipesPositions);
    if (result == DashStepResult.died) {
      _diedAtSeq = seq;
    }
    return result;
  }

  /// The input command to send now, if any: right away after a jump (so the
  /// others see it as soon as possible), otherwise a heartbeat every
  /// [heartbeatEveryTicks].
  InputPacket? pollInputPacket() {
    if (!hasLife || _serverConfirmedDeath) {
      return null;
    }
    if (_diedAtSeq >= 0 && seq - _diedAtSeq > sendAfterDeathTicks) {
      return null;
    }
    if (seq <= _lastSentUpToSeq) {
      return null;
    }
    if (!_jumpedSinceLastSend && seq - _lastSentUpToSeq < heartbeatEveryTicks) {
      return null;
    }
    _lastSentUpToSeq = seq;
    _jumpedSinceLastSend = false;
    return InputPacket(
      lifeStartSeq: lifeStartSeq,
      upToSeq: seq,
      // Every jump the server hasn't acknowledged, so a life whose first
      // packet the server couldn't accept yet still gets all its jumps.
      jumpSeqs: List.of(_unackedJumps),
    );
  }

  /// Applies the server's state of our dash. Returns true if the server says
  /// we died while we predicted we're alive.
  bool reconcile(SnapshotEntry entry) {
    final sim = _sim;
    if (sim == null || lifeStartSeq < 0) {
      return false;
    }
    // An entry of a previous life (or of the time before the server started
    // this one) says nothing about this life.
    if (entry.seq < lifeStartSeq - 1) {
      return false;
    }
    switch (entry.playingState) {
      case PlayingState.playing:
        break;
      case PlayingState.gameOver:
        if (entry.seq < lifeStartSeq) {
          return false;
        }
        _serverConfirmedDeath = true;
        _ackedSeq = entry.seq;
        if (!sim.alive) {
          return false;
        }
        _correctTo(
          DashSim(
            x: entry.x,
            y: entry.y,
            vy: 0,
            alive: false,
            score: entry.score,
            firstPipe: sim.firstPipe,
            lastScoredPipe: entry.lastScoredPipe,
          ),
        );
        _diedAtSeq = seq;
        return true;
      case PlayingState.idle || PlayingState.paused:
        return false;
    }

    if (entry.seq < _ackedSeq) {
      return false;
    }
    _ackedSeq = entry.seq;
    _unackedJumps.removeWhere((jumpSeq) => jumpSeq <= entry.seq);

    final replayed = DashSim(
      x: entry.x,
      y: entry.y,
      vy: entry.vy,
      alive: true,
      score: entry.score,
      firstPipe: sim.firstPipe,
      lastScoredPipe: entry.lastScoredPipe,
    );
    if (entry.seq > seq) {
      // The server simulated further than we did (we were frozen, e.g. the
      // tab was in the background). Jump forward to it.
      seq = entry.seq;
      _lastSentUpToSeq = math.max(_lastSentUpToSeq, seq);
    } else {
      var jumpIndex = 0;
      for (var t = entry.seq + 1; t <= seq && replayed.alive; t++) {
        while (jumpIndex < _unackedJumps.length &&
            _unackedJumps[jumpIndex] < t) {
          jumpIndex++;
        }
        final jump =
            jumpIndex < _unackedJumps.length && _unackedJumps[jumpIndex] == t;
        DashPhysics.step(replayed, jump, pipesPositions);
      }
    }

    final dx = replayed.x - sim.x;
    final dy = replayed.y - sim.y;
    final mismatch =
        dx.abs() > _maxPredictionError ||
        dy.abs() > _maxPredictionError ||
        (replayed.vy - sim.vy).abs() > _maxPredictionError ||
        replayed.alive != sim.alive ||
        replayed.score != sim.score;
    if (!mismatch) {
      return false;
    }
    if (!sim.alive) {
      // We already showed our death; the server will get there too (it keeps
      // simulating us without jumps). Don't bring the dash back to life.
      return false;
    }
    _correctTo(replayed);
    if (!replayed.alive) {
      _diedAtSeq = seq;
      return true;
    }
    return false;
  }

  void _correctTo(DashSim corrected) {
    final sim = _sim!;
    corrections++;
    // Keep the dash where it is on screen and slide it to the corrected
    // position over the next frames.
    _errorX += sim.x - corrected.x;
    _errorY += sim.y - corrected.y;
    if (_errorX.abs() > 200 || _errorY.abs() > 200) {
      // Too far to slide; just jump there.
      _errorX = 0;
      _errorY = 0;
    }
    _sim = corrected;
    _previousSim = corrected.copy();
  }

  /// Decays the visual prediction error. Call once per frame.
  void smoothError(double dt) {
    if (_errorX == 0 && _errorY == 0) {
      return;
    }
    final keep = math.exp(-dt / (errorSmoothingSeconds / 3));
    _errorX *= keep;
    _errorY *= keep;
    if (_errorX.abs() < 0.01 && _errorY.abs() < 0.01) {
      _errorX = 0;
      _errorY = 0;
    }
  }

  /// Where to draw the dash: between the last two ticks ([alpha] is how far
  /// we are into the next tick, 0..1) plus the smoothed prediction error.
  ({double x, double y, double vy})? renderState(double alpha) {
    final sim = _sim;
    final previous = _previousSim;
    if (sim == null || previous == null) {
      return null;
    }
    return (
      x: previous.x + (sim.x - previous.x) * alpha + _errorX,
      y: previous.y + (sim.y - previous.y) * alpha + _errorY,
      vy: sim.vy,
    );
  }

  /// Forgets the current life (e.g. while waiting to respawn).
  void endLife() {
    _sim = null;
    _previousSim = null;
    lifeStartSeq = -1;
    _unackedJumps.clear();
  }
}
