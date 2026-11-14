import 'package:equatable/equatable.dart';
import 'package:nakama/nakama.dart';

import 'match_phase.dart';
import 'player_state.dart';

class MatchState with Equatable {
  final DateTime matchInitializedAt;
  final DateTime matchRunsAt;
  final DateTime matchFinishesAt;
  final MatchPhase currentPhase;
  final List<UserPresence> presences;
  final Map<String, PlayerState> players;
  final List<double> pipesPositions;

  /// The user ids of the players of a running match. Snapshots refer to a
  /// player by its index in this list.
  final List<String> roster;

  MatchState({
    required this.matchInitializedAt,
    required this.matchRunsAt,
    required this.matchFinishesAt,
    required this.currentPhase,
    required this.presences,
    required this.players,
    required this.pipesPositions,
    this.roster = const [],
  });

  MatchState copyWith({
    DateTime? matchInitializedAt,
    DateTime? matchRunsAt,
    DateTime? matchFinishesAt,
    MatchPhase? currentPhase,
    List<UserPresence>? presences,
    Map<String, PlayerState>? players,
    List<double>? pipesPositions,
    List<String>? roster,
  }) => MatchState(
    matchInitializedAt: matchInitializedAt ?? this.matchInitializedAt,
    matchRunsAt: matchRunsAt ?? this.matchRunsAt,
    matchFinishesAt: matchFinishesAt ?? this.matchFinishesAt,
    currentPhase: currentPhase ?? this.currentPhase,
    presences: presences ?? this.presences,
    players: players ?? this.players,
    pipesPositions: pipesPositions ?? this.pipesPositions,
    roster: roster ?? this.roster,
  );

  factory MatchState.fromJson(Map<String, dynamic> json) => MatchState(
    matchInitializedAt: DateTime.fromMillisecondsSinceEpoch(
      json['matchInitializedAt'],
    ),
    matchRunsAt: DateTime.fromMillisecondsSinceEpoch(json['matchRunsAt']),
    matchFinishesAt: DateTime.fromMillisecondsSinceEpoch(
      json['matchFinishesAt'],
    ),
    currentPhase: MatchPhase.values[json['currentPhase']],
    presences: (json['presences'] as List)
        .map(
          (e) => UserPresence(
            userId: e['userId'],
            sessionId: e['sessionId'],
            username: e['username'],
            persistence: false,
          ),
        )
        .toList(),
    players: (json['players'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, PlayerState.fromJson(v)),
    ),
    pipesPositions: (json['pipesPositions'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
    roster: (json['roster'] as List?)?.cast<String>() ?? const [],
  );

  @override
  List<Object?> get props => [
    matchInitializedAt,
    matchRunsAt,
    matchFinishesAt,
    currentPhase,
    presences,
    players,
    pipesPositions,
    roster,
  ];
}
