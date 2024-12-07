import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/player_state.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';

class LocalPlayerState with EquatableMixin {
  final String playerId;
  final String displayName;
  final int score;
  final int diedCount;
  final PlayingState playingState;
  final double? spawnsAgainIn;
  final double jumpForce;
  final double velocityX;

  LocalPlayerState({
    required this.playerId,
    required this.displayName,
    required this.score,
    required this.diedCount,
    required this.playingState,
    required this.spawnsAgainIn,
    required this.jumpForce,
    required this.velocityX,
  });

  LocalPlayerState copyWith({
    String? playerId,
    String? displayName,
    int? score,
    int? diedCount,
    PlayingState? playingState,
    ValueWrapper<double>? spawnsAgainIn,
    double? jumpForce,
    double? velocityX,
  }) =>
      LocalPlayerState(
        playerId: playerId ?? this.playerId,
        displayName: displayName ?? this.displayName,
        score: score ?? this.score,
        diedCount: diedCount ?? this.diedCount,
        playingState: playingState ?? this.playingState,
        spawnsAgainIn:
            spawnsAgainIn != null ? spawnsAgainIn.value : this.spawnsAgainIn,
        jumpForce: jumpForce ?? this.jumpForce,
        velocityX: velocityX ?? this.velocityX,
      );

  @override
  List<Object?> get props => [
        playerId,
        displayName,
        score,
        diedCount,
        playingState,
        spawnsAgainIn,
        jumpForce,
        velocityX,
      ];
}

extension PlayerStateExtensions on PlayerState {
  LocalPlayerState toLocalPlayerState() => LocalPlayerState(
        playerId: userId,
        displayName: displayName,
        score: score,
        diedCount: diedCount,
        playingState: playingState,
        spawnsAgainIn: spawnsAgainIn,
        jumpForce: jumpForce,
        velocityX: velocityX,
      );
}