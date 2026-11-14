// Binary messages of the hot path (sent many times a second). Their twin on
// the server is data/modules/functions/src/netcode/net_protocol.ts in the
// flappy_dash_nakama repo. Everything is little endian.

import 'dart:typed_data';

import 'package:flappy_dash/domain/entities/playing_state.dart';

/// Client -> server. "In my life that started at tick [lifeStartSeq], I
/// simulated every tick up to [upToSeq], and I jumped in these ticks".
///
///   u8  version (1)
///   u32 lifeStartSeq
///   u32 upToSeq
///   u8  jumpCount
///   u32 jumpSeq * jumpCount
class InputPacket {
  const InputPacket({
    required this.lifeStartSeq,
    required this.upToSeq,
    required this.jumpSeqs,
  });

  static const version = 1;
  static const headerSize = 10;
  static const maxJumps = 255;

  final int lifeStartSeq;
  final int upToSeq;
  final List<int> jumpSeqs;

  Uint8List toBytes() {
    final jumps = jumpSeqs.length > maxJumps
        ? jumpSeqs.sublist(jumpSeqs.length - maxJumps)
        : jumpSeqs;
    final data = ByteData(headerSize + jumps.length * 4);
    data.setUint8(0, version);
    data.setUint32(1, lifeStartSeq, Endian.little);
    data.setUint32(5, upToSeq, Endian.little);
    data.setUint8(9, jumps.length);
    for (var i = 0; i < jumps.length; i++) {
      data.setUint32(headerSize + i * 4, jumps[i], Endian.little);
    }
    return data.buffer.asUint8List();
  }

  static InputPacket? fromBytes(List<int> bytes) {
    if (bytes.length < headerSize) {
      return null;
    }
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    if (data.getUint8(0) != version) {
      return null;
    }
    final count = data.getUint8(9);
    if (bytes.length < headerSize + count * 4) {
      return null;
    }
    return InputPacket(
      lifeStartSeq: data.getUint32(1, Endian.little),
      upToSeq: data.getUint32(5, Endian.little),
      jumpSeqs: [
        for (var i = 0; i < count; i++)
          data.getUint32(headerSize + i * 4, Endian.little),
      ],
    );
  }

  @override
  String toString() =>
      'InputPacket(life: $lifeStartSeq, upTo: $upToSeq, jumps: $jumpSeqs)';
}

/// Server -> clients, every match loop (20/s) while the match runs.
///
///   u8  kind (0 = delta: only players that changed, 1 = full: every player)
///   u32 serverTime (ms since the match was created)
///   u8  entryCount
///   entry * entryCount (22 bytes each, see [SnapshotEntry])
class Snapshot {
  const Snapshot({
    required this.isFull,
    required this.serverTime,
    required this.entries,
  });

  static const headerSize = 6;
  static const entrySize = 22;

  final bool isFull;
  final int serverTime;
  final List<SnapshotEntry> entries;

  static Snapshot fromBytes(List<int> bytes) {
    final data = ByteData.sublistView(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
    );
    final count = data.getUint8(5);
    if (data.lengthInBytes < headerSize + count * entrySize) {
      throw FormatException('Snapshot too short: ${data.lengthInBytes}');
    }
    final entries = <SnapshotEntry>[];
    var o = headerSize;
    for (var i = 0; i < count; i++) {
      entries.add(
        SnapshotEntry(
          rosterIndex: data.getUint8(o),
          playingState: _playingStateOf(data.getUint8(o + 1)),
          score: data.getUint16(o + 2, Endian.little),
          seq: data.getUint32(o + 4, Endian.little),
          x: data.getFloat32(o + 8, Endian.little),
          y: data.getFloat32(o + 12, Endian.little),
          vy: data.getFloat32(o + 16, Endian.little),
          lastScoredPipe: data.getUint16(o + 20, Endian.little),
        ),
      );
      o += entrySize;
    }
    return Snapshot(
      isFull: data.getUint8(0) == 1,
      serverTime: data.getUint32(1, Endian.little),
      entries: entries,
    );
  }

  // The server's states: 0 idle, 1 playing, 2 died.
  static PlayingState _playingStateOf(int value) => switch (value) {
    1 => PlayingState.playing,
    2 => PlayingState.gameOver,
    _ => PlayingState.idle,
  };
}

class SnapshotEntry {
  const SnapshotEntry({
    required this.rosterIndex,
    required this.playingState,
    required this.score,
    required this.seq,
    required this.x,
    required this.y,
    required this.vy,
    required this.lastScoredPipe,
  });

  /// Index into the match state's roster (the list of playing user ids).
  final int rosterIndex;
  final PlayingState playingState;
  final int score;

  /// The last input tick of this player the server simulated.
  final int seq;

  /// Unwrapped x: distance since the spawn point (see dash_physics.dart).
  final double x;
  final double y;
  final double vy;
  final int lastScoredPipe;
}
