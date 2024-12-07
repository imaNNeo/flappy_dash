import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';

class PlayerState with EquatableMixin {
  final String userId;
  final String displayName;
  final bool isInLobby;
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final int score;
  final int diedCount;
  final PlayingState playingState;
  final double? spawnsAgainIn;
  final double jumpForce;

  PlayerState({
    required this.userId,
    required this.displayName,
    required this.isInLobby,
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.score,
    required this.diedCount,
    required this.playingState,
    required this.spawnsAgainIn,
    required this.jumpForce,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) => PlayerState(
        userId: json['userId'],
        displayName: json['displayName'],
        isInLobby: json['isInLobby'],
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        velocityX: (json['velocityX'] as num).toDouble(),
        velocityY: (json['velocityY'] as num).toDouble(),
        score: json['score'],
        diedCount: json['diedCount'],
        playingState: PlayingState.values[json['playingState']],
        spawnsAgainIn:
            json.containsKey('spawnsAgainIn') ? json['spawnsAgainIn'] : null,
        jumpForce: (json['jumpForce'] as num).toDouble(),
      );

  // copyWith
  PlayerState copyWith({
    String? userId,
    String? displayName,
    bool? isInLobby,
    double? x,
    double? y,
    double? velocityX,
    double? velocityY,
    int? score,
    int? diedCount,
    PlayingState? playingState,
    ValueWrapper<double>? spawnsAgainIn,
    double? jumpForce,
  }) =>
      PlayerState(
        userId: userId ?? this.userId,
        displayName: displayName ?? this.displayName,
        isInLobby: isInLobby ?? this.isInLobby,
        x: x ?? this.x,
        y: y ?? this.y,
        velocityX: velocityX ?? this.velocityX,
        velocityY: velocityY ?? this.velocityY,
        score: score ?? this.score,
        diedCount: diedCount ?? this.diedCount,
        playingState: playingState ?? this.playingState,
        spawnsAgainIn:
            spawnsAgainIn != null ? spawnsAgainIn.value : this.spawnsAgainIn,
        jumpForce: jumpForce ?? this.jumpForce,
      );

  @override
  List<Object?> get props => [
        userId,
        displayName,
        isInLobby,
        x,
        y,
        velocityX,
        velocityY,
        score,
        diedCount,
        playingState,
        spawnsAgainIn,
        jumpForce,
      ];
}
