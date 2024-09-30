import 'package:equatable/equatable.dart';
import 'package:nakama/nakama.dart';

import 'match_phase.dart';
import 'player_state.dart';

class MatchState with EquatableMixin {
  final DateTime matchInitializedAt;
  final DateTime matchRunsAt;
  final DateTime matchFinishesAt;
  final MatchPhase currentPhase;
  final List<UserPresence> presences;
  final Map<String, PlayerState> players;

  MatchState({
    required this.matchInitializedAt,
    required this.matchRunsAt,
    required this.matchFinishesAt,
    required this.currentPhase,
    required this.presences,
    required this.players,
  });

  MatchState copyWith({
    DateTime? matchInitializedAt,
    DateTime? matchRunsAt,
    DateTime? matchFinishesAt,
    MatchPhase? currentPhase,
    List<UserPresence>? presences,
    Map<String, PlayerState>? players,
  }) =>
      MatchState(
        matchInitializedAt: matchInitializedAt ?? this.matchInitializedAt,
        matchRunsAt: matchRunsAt ?? this.matchRunsAt,
        matchFinishesAt: matchFinishesAt ?? this.matchFinishesAt,
        currentPhase: currentPhase ?? this.currentPhase,
        presences: presences ?? this.presences,
        players: players ?? this.players,
      );

  factory MatchState.fromJson(Map<String, dynamic> json) => MatchState(
    matchInitializedAt:
    DateTime.fromMillisecondsSinceEpoch(json['matchInitializedAt']),
    matchRunsAt: DateTime.fromMillisecondsSinceEpoch(json['matchRunsAt']),
    matchFinishesAt:
    DateTime.fromMillisecondsSinceEpoch(json['matchFinishesAt']),
    currentPhase: MatchPhase.values[json['currentPhase']],
    presences: (json['presences'] as List)
        .map((e) => UserPresence(
      userId: e['userId'],
      sessionId: e['sessionId'],
      username: e['username'],
      persistence: false,
    ))
        .toList(),
    players: (json['players'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, PlayerState.fromJson(v)),
    ),
  );

  @override
  List<Object?> get props => [
    matchInitializedAt,
    matchRunsAt,
    matchFinishesAt,
    currentPhase,
    presences,
    players,
  ];
}
