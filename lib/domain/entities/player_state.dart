import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';

class PlayerState with EquatableMixin {
  final String userId;
  final String displayName;
  final bool isInLobby;
  final double lastKnownX;
  final int score;
  final PlayingState playingState;

  PlayerState({
    required this.userId,
    required this.displayName,
    required this.isInLobby,
    required this.lastKnownX,
    required this.score,
    required this.playingState,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        userId: json['userId'],
        displayName: json['displayName'],
        isInLobby: json['isInLobby'],
        lastKnownX: double.parse(json['lastKnownX'].toString()),
        score: json['score'],
        playingState: PlayingState.values[json['playingState']],
      );

  @override
  List<Object?> get props => [
        userId,
        displayName,
        isInLobby,
        lastKnownX,
        score,
        playingState,
      ];
}
