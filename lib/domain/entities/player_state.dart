import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';

class PlayerState with EquatableMixin {
  final String userId;
  final String displayName;
  final bool isInLobby;
  final double lastKnownX;
  final double lastKnownY;
  final double lastKnownVelocityY;
  final int score;
  final PlayingState playingState;
  final DateTime spawnsAgainAt;

  PlayerState({
    required this.userId,
    required this.displayName,
    required this.isInLobby,
    required this.lastKnownX,
    required this.lastKnownY,
    required this.lastKnownVelocityY,
    required this.score,
    required this.playingState,
    required this.spawnsAgainAt,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        userId: json['userId'],
        displayName: json['displayName'],
        isInLobby: json['isInLobby'],
        lastKnownX: double.parse(json['lastKnownX'].toString()),
        lastKnownY: double.parse(json['lastKnownY'].toString()),
        lastKnownVelocityY: double.parse(json['lastKnownVelocityY'].toString()),
        score: json['score'],
        playingState: PlayingState.values[json['playingState']],
        spawnsAgainAt: DateTime.fromMillisecondsSinceEpoch(
          json['spawnsAgainAt'],
        ),
      );

  @override
  List<Object?> get props => [
        userId,
        displayName,
        isInLobby,
        lastKnownX,
        lastKnownY,
        lastKnownVelocityY,
        score,
        playingState,
        spawnsAgainAt,
      ];
}
