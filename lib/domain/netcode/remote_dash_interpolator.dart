import 'package:flappy_dash/domain/entities/playing_state.dart';

import 'dash_physics.dart';
import 'net_protocol.dart';

/// Entity interpolation for another player's dash
/// (https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking#Entity_interpolation).
///
/// Snapshots arrive 20 times a second, each with the dash's state at one of
/// its player's ticks. Instead of drawing the newest state (which would jump
/// every 50ms), we draw the dash a little in the past ([delayTicks]) and
/// interpolate between the two states around that moment. If the next state
/// is late, we extrapolate with the physics (no jumps) for a short while.
///
/// The timeline is the other player's own tick numbers, not our clock: the
/// server simulates every dash on its player's ticks, so the movement between
/// two states is exactly (tick difference) * 1/60s, whatever the network did.
class RemoteDashInterpolator {
  /// How far in the past we draw other dashes: ~133ms. Snapshots come every
  /// 3 ticks and the server gets inputs every 3 ticks, so this leaves room
  /// for one late snapshot (Source uses 100ms with 20 snapshots/s).
  static const delayTicks = 8;

  /// Extrapolate at most this far past the last known state (Source: 250ms).
  static const maxExtrapolationTicks = 15;

  /// If our playback is further than this from where it should be (a new
  /// life, a long freeze), jump instead of catching up smoothly.
  static const snapTicks = 20;

  final List<_Sample> _samples = [];
  double _renderSeq = 0;
  bool _hasNewSample = false;

  bool get hasState => _samples.isNotEmpty;

  void addSnapshotEntry(SnapshotEntry entry) {
    final sample = _Sample(
      seq: entry.seq,
      x: entry.x,
      y: entry.y,
      vy: entry.vy,
      state: entry.playingState,
    );
    _hasNewSample = true;
    if (_samples.isEmpty) {
      _samples.add(sample);
      _renderSeq = (sample.seq - delayTicks).toDouble();
      return;
    }
    final last = _samples.last;
    final isNewLife =
        sample.state.isPlaying &&
        (!last.state.isPlaying || sample.seq < last.seq);
    if (isNewLife) {
      // Show the dash where it was (idle at its spawn point) until the new
      // life's first tick, then play it.
      _samples
        ..clear()
        ..add(sample);
      _renderSeq = (sample.seq - delayTicks).toDouble();
      return;
    }
    if (sample.seq < last.seq) {
      // Out of date (can't happen on one ordered connection, but be safe).
      return;
    }
    if (sample.seq == last.seq && sample.state == last.state) {
      _samples[_samples.length - 1] = sample;
      return;
    }
    _samples.add(sample);
  }

  /// Moves the playback forward. Call once per frame.
  void advance(double dt) {
    if (_samples.isEmpty) {
      return;
    }
    final last = _samples.last;
    if (last.state.isPlaying) {
      final target = last.seq - delayTicks;
      final error = target - _renderSeq;
      final hasNewSample = _hasNewSample;
      _hasNewSample = false;
      // Far behind: jump ahead. Far ahead: only jump back once new states
      // come in (while they don't, we extrapolate and then hold).
      if (error > snapTicks || (error < -snapTicks && hasNewSample)) {
        _renderSeq = target.toDouble();
      } else {
        // Catch up (or slow down) by at most 10% speed, so it's not visible.
        final maxCorrection = dt * DashPhysics.tickRate * 0.1;
        _renderSeq += (error * dt * 2).clamp(-maxCorrection, maxCorrection);
      }
    }
    // When the last state isn't playing (died, idle), nothing new comes
    // before the next life; just play to the end.
    _renderSeq += dt * DashPhysics.tickRate;

    // Forget what we have played already (keep the one we're past).
    while (_samples.length > 2 && _samples[1].seq <= _renderSeq) {
      _samples.removeAt(0);
    }
  }

  /// The state to draw now.
  RemoteDashState? current() {
    if (_samples.isEmpty) {
      return null;
    }
    final r = _renderSeq;
    final first = _samples.first;
    if (r <= first.seq) {
      return first.toState();
    }
    for (var i = 0; i < _samples.length - 1; i++) {
      final a = _samples[i];
      final b = _samples[i + 1];
      if (r >= a.seq && r < b.seq) {
        // Slide into the place it died at too, but never towards a spawn
        // point.
        final bMoves = b.state.isPlaying || b.state.isGameOver;
        if (!a.state.isPlaying || !bMoves || b.seq == a.seq) {
          return a.toState();
        }
        final t = (r - a.seq) / (b.seq - a.seq);
        return RemoteDashState(
          x: a.x + (b.x - a.x) * t,
          y: a.y + (b.y - a.y) * t,
          playingState: PlayingState.playing,
        );
      }
    }
    final last = _samples.last;
    if (!last.state.isPlaying) {
      return last.toState();
    }
    // The next state is late: extrapolate (no jumps) for a little while.
    final ticks = (r - last.seq).clamp(0.0, maxExtrapolationTicks.toDouble());
    final seconds = ticks * DashPhysics.dt;
    return RemoteDashState(
      x: last.x + DashPhysics.dashSpeed * seconds,
      y:
          last.y +
          last.vy * seconds +
          0.5 * DashPhysics.gravity * seconds * seconds,
      playingState: PlayingState.playing,
    );
  }
}

class RemoteDashState {
  const RemoteDashState({
    required this.x,
    required this.y,
    required this.playingState,
  });

  final double x;
  final double y;
  final PlayingState playingState;
}

class _Sample {
  const _Sample({
    required this.seq,
    required this.x,
    required this.y,
    required this.vy,
    required this.state,
  });

  final int seq;
  final double x;
  final double y;
  final double vy;
  final PlayingState state;

  RemoteDashState toState() => RemoteDashState(x: x, y: y, playingState: state);
}
