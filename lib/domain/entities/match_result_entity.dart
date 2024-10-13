import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/user_json_parser.dart';
import 'package:nakama/nakama.dart';

class MatchResultEntity with EquatableMixin {
  DateTime initializedAt;
  DateTime startedAt;
  DateTime finishedAt;
  List<MatchScoreEntity> scores;

  MatchResultEntity({
    required this.initializedAt,
    required this.startedAt,
    required this.finishedAt,
    required this.scores,
  });

  // fromJson
  factory MatchResultEntity.fromJson(Map<String, dynamic> json) =>
      MatchResultEntity(
        initializedAt:
            DateTime.fromMillisecondsSinceEpoch(json['initializedAt']),
        startedAt: DateTime.fromMillisecondsSinceEpoch(json['startedAt']),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(json['finishedAt']),
        scores: json['scores']
            .map<MatchScoreEntity>((e) => MatchScoreEntity.fromJson(e))
            .toList(),
      );

  // toJson
  Map<String, dynamic> toJson() => {
        'initializedAt': initializedAt.millisecondsSinceEpoch,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'finishedAt': finishedAt.millisecondsSinceEpoch,
        'scores': scores.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        initializedAt,
        startedAt,
        finishedAt,
        scores,
      ];
}

class MatchScoreEntity with EquatableMixin {
  final int score;
  final User user;

  MatchScoreEntity({
    required this.score,
    required this.user,
  });

  // fromJson
  factory MatchScoreEntity.fromJson(Map<String, dynamic> json) =>
      MatchScoreEntity(
        score: json['score'],
        user: User.fromJson(UserJsonParser.convertComingJson(json['user'])),
      );

  // toJson
  Map<String, dynamic> toJson() => {
        'score': score,
        'user': UserJsonParser.convertOutgoingJson(user.toJson()),
      };

  @override
  List<Object?> get props => [
        score,
        user,
      ];
}
