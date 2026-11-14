import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';

class PlayerState with Equatable {
  final String userId;
  final String displayName;
  final bool isInLobby;
  final double lastKnownX;
  final double lastKnownY;
  final double lastKnownVelocityY;
  final int score;
  final PlayingState playingState;
  final DateTime spawnsAgainAt;

  /// A server-side bot (it has no presence and plays on the server).
  final bool isBot;

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
    this.isBot = false,
  });

  PlayerState copyWith({int? score}) => PlayerState(
    userId: userId,
    displayName: displayName,
    isInLobby: isInLobby,
    lastKnownX: lastKnownX,
    lastKnownY: lastKnownY,
    lastKnownVelocityY: lastKnownVelocityY,
    score: score ?? this.score,
    playingState: playingState,
    spawnsAgainAt: spawnsAgainAt,
    isBot: isBot,
  );

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
    userId: json['userId'],
    displayName: json['displayName'],
    isInLobby: json['isInLobby'],
    lastKnownX: double.parse(json['lastKnownX'].toString()),
    lastKnownY: double.parse(json['lastKnownY'].toString()),
    lastKnownVelocityY: double.parse(json['lastKnownVelocityY'].toString()),
    score: json['score'],
    playingState: PlayingState.values[json['playingState']],
    spawnsAgainAt: DateTime.fromMillisecondsSinceEpoch(json['spawnsAgainAt']),
    isBot: json['isBot'] == true,
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
    isBot,
  ];
}
