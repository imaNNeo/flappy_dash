import 'package:equatable/equatable.dart';
import 'package:nakama/nakama.dart';

import 'match_phase.dart';
import 'player_state.dart';

class MatchState with EquatableMixin {
  final int playingTickRate;
  final int playingTickNumber;
  final double pipesDistance;
  final List<double> pipesNormalizedYPositions;
  final double pipesHoleGap;
  final double pipesYRange;
  final double pipeWidth;
  final DateTime matchInitializedAt;
  final DateTime matchRunsAt;
  final DateTime matchFinishesAt;
  final MatchPhase currentPhase;
  final List<UserPresence> presences;
  final num gravityY;
  final Map<String, PlayerState> players;
  final double playersInitialXSpeed;
  final double playerSpawnsAgainAfter;

  MatchState({
    required this.playingTickRate,
    required this.playingTickNumber,
    required this.pipesDistance,
    required this.pipesNormalizedYPositions,
    required this.pipesHoleGap,
    required this.pipesYRange,
    required this.pipeWidth,
    required this.matchInitializedAt,
    required this.matchRunsAt,
    required this.matchFinishesAt,
    required this.currentPhase,
    required this.presences,
    required this.gravityY,
    required this.players,
    required this.playersInitialXSpeed,
    required this.playerSpawnsAgainAfter,
  });

  MatchState copyWith({
    int? playingTickRate,
    int? playingTickNumber,
    double? pipesDistance,
    List<double>? pipesNormalizedYPositions,
    double? pipesHoleGap,
    double? pipesYRange,
    double? pipeWidth,
    DateTime? matchInitializedAt,
    DateTime? matchRunsAt,
    DateTime? matchFinishesAt,
    MatchPhase? currentPhase,
    List<UserPresence>? presences,
    double? gravityY,
    Map<String, PlayerState>? players,
    double? playersInitialXSpeed,
    double? playerSpawnsAgainAfter,
  }) =>
      MatchState(
        playingTickRate: playingTickRate ?? this.playingTickRate,
        playingTickNumber: playingTickNumber ?? this.playingTickNumber,
        pipesDistance: pipesDistance ?? this.pipesDistance,
        pipesNormalizedYPositions:
            pipesNormalizedYPositions ?? this.pipesNormalizedYPositions,
        pipesHoleGap: pipesHoleGap ?? this.pipesHoleGap,
        pipesYRange: pipesYRange ?? this.pipesYRange,
        pipeWidth: pipeWidth ?? this.pipeWidth,
        matchInitializedAt: matchInitializedAt ?? this.matchInitializedAt,
        matchRunsAt: matchRunsAt ?? this.matchRunsAt,
        matchFinishesAt: matchFinishesAt ?? this.matchFinishesAt,
        currentPhase: currentPhase ?? this.currentPhase,
        presences: presences ?? this.presences,
        gravityY: gravityY ?? this.gravityY,
        players: players ?? this.players,
        playersInitialXSpeed: playersInitialXSpeed ?? this.playersInitialXSpeed,
        playerSpawnsAgainAfter:
            playerSpawnsAgainAfter ?? this.playerSpawnsAgainAfter,
      );

  factory MatchState.fromJson(Map<String, dynamic> json) => MatchState(
        playingTickRate: json['playingTickRate'] as int,
        playingTickNumber: json['playingTickNumber'] as int,
        pipesDistance: (json['pipesDistance'] as num).toDouble(),
        pipesNormalizedYPositions: (json['pipesNormalizedYPositions'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
        pipesHoleGap: (json['pipesHoleGap'] as num).toDouble(),
        pipesYRange: (json['pipesYRange'] as num).toDouble(),
        pipeWidth: (json['pipeWidth'] as num).toDouble(),
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
        gravityY: (json['gravityY'] as num).toDouble(),
        players: (json['players'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, PlayerState.fromJson(v)),
        ),
        playersInitialXSpeed: (json['playersInitialXSpeed'] as num).toDouble(),
        playerSpawnsAgainAfter:
            (json['playerSpawnsAgainAfter'] as num) / 1000,
      );

  @override
  List<Object?> get props => [
        playingTickRate,
        playingTickNumber,
        pipesDistance,
        pipesNormalizedYPositions,
        pipesHoleGap,
        pipesYRange,
        pipeWidth,
        matchInitializedAt,
        matchRunsAt,
        matchFinishesAt,
        currentPhase,
        presences,
        gravityY,
        players,
        playersInitialXSpeed,
        playerSpawnsAgainAfter,
      ];
}
