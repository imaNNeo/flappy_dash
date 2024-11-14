import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/user_json_parser.dart';
import 'package:nakama/nakama.dart';

class MatchOverviewEntity with EquatableMixin {
  String id;
  DateTime initializedAt;
  DateTime startedAt;
  DateTime finishedAt;
  List<MatchScoreEntity> scores;

  MatchOverviewEntity({
    required this.id,
    required this.initializedAt,
    required this.startedAt,
    required this.finishedAt,
    required this.scores,
  });

  MatchScoreEntity? getMyScore(String? userId) {
    try {
      return scores.firstWhere((element) => element.user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // fromJson
  factory MatchOverviewEntity.fromJson(Map<String, dynamic> json) =>
      MatchOverviewEntity(
        id: json['id'],
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
        'id': id,
        'initializedAt': initializedAt.millisecondsSinceEpoch,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'finishedAt': finishedAt.millisecondsSinceEpoch,
        'scores': scores.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
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
