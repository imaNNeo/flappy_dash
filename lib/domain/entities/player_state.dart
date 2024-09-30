import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';

class PlayerState with EquatableMixin {
  final bool isInLobby;
  final double lastKnownX;
  final int score;
  final PlayingState playingState;

  PlayerState({
    required this.isInLobby,
    required this.lastKnownX,
    required this.score,
    required this.playingState,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
    isInLobby: json['isInLobby'],
    lastKnownX: double.parse(json['lastKnownX'].toString()),
    score: json['score'],
    playingState: PlayingState.values[json['playingState']],
  );

  @override
  List<Object?> get props => [
    isInLobby,
    lastKnownX,
    score,
    playingState,
  ];
}