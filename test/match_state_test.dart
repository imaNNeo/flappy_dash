import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/match_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The server sends JSON produced by JavaScript, where 0.0 is written as `0`.
  Map<String, dynamic> serverState() => {
    'matchInitializedAt': 1700000000000,
    'matchRunsAt': 1700000030000,
    'matchFinishesAt': 0,
    'currentPhase': 1,
    'presences': [
      {'userId': 'u1', 'sessionId': 's1', 'username': 'one', 'node': 'nakama1'},
    ],
    'players': {
      'u1': {
        'isInLobby': true,
        'lastKnownX': 0,
        'lastKnownY': -12.5,
        'lastKnownVelocityY': 0,
        'score': 3,
        'playingState': 1,
        'displayName': 'One',
        'userId': 'u1',
        'spawnsAgainAt': 0,
        'lastPing': 42,
      },
    },
    'pipesPositions': [0, 0.5, -1],
    'matchFinishTextSent': false,
  };

  test('parses whole numbers sent where doubles are expected', () {
    final state = MatchState.fromJson(serverState());
    expect(state.currentPhase, MatchPhase.running);
    expect(state.pipesPositions, [0.0, 0.5, -1.0]);
    expect(state.players['u1']!.lastKnownX, 0.0);
    expect(state.players['u1']!.lastKnownY, -12.5);
    expect(state.players['u1']!.score, 3);
    expect(state.presences.single.sessionId, 's1');
  });
}
