import 'package:equatable/equatable.dart';

import 'playing_state.dart';

enum MatchDiffCode {
  playerSpawned(1),
  playerStarted(2),
  playerJumped(3),
  playerMoved(4),
  playerDied(5),
  playerScored(6),
  playerSpawnTimeDecreased(7);

  final int code;

  const MatchDiffCode(this.code);

  static MatchDiffCode parse(int code) {
    for (final diffCode in values) {
      if (diffCode.code == code) {
        return diffCode;
      }
    }
    throw ArgumentError('Unknown MatchDiffCode: $code');
  }
}

sealed class MatchDiffInfoEntity with EquatableMixin {
  static MatchDiffInfoEntity fromJson(Map<String, dynamic> json) {
    final diffCode = MatchDiffCode.parse(json['diffCode'] as int);
    return switch (diffCode) {
      MatchDiffCode.playerSpawned => MatchDiffInfoPlayerSpawned.fromJson(json),
      MatchDiffCode.playerStarted => MatchDiffInfoPlayerStarted.fromJson(json),
      MatchDiffCode.playerJumped => MatchDiffInfoPlayerJumped.fromJson(json),
      MatchDiffCode.playerMoved => MatchDiffInfoPlayerMoved.fromJson(json),
      MatchDiffCode.playerDied => MatchDiffInfoPlayerDied.fromJson(json),
      MatchDiffCode.playerScored => MatchDiffInfoPlayerScored.fromJson(json),
      MatchDiffCode.playerSpawnTimeDecreased =>
        MatchDiffInfoPlayerSpawnTimeDecreased.fromJson(json),
    };
  }

  MatchDiffCode get diffCode;
}

class MatchDiffInfoPlayerSpawned extends MatchDiffInfoEntity {
  final String userId;
  final double x;
  final double y;

  MatchDiffInfoPlayerSpawned(this.userId, this.x, this.y);

  factory MatchDiffInfoPlayerSpawned.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerSpawned(
        json['userId'] as String,
        json['x'] as double,
        json['y'] as double,
      );

  @override
  List<Object?> get props => [
        userId,
        x,
        y,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerSpawned;
}

class MatchDiffInfoPlayerStarted extends MatchDiffInfoEntity {
  final String userId;
  final PlayingState playingState;
  final double velocityX;

  MatchDiffInfoPlayerStarted(this.userId, this.playingState, this.velocityX);

  factory MatchDiffInfoPlayerStarted.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerStarted(
        json['userId'] as String,
        PlayingState.values[json['playingState']],
        json['velocityX'] as double,
      );

  @override
  List<Object?> get props => [
        userId,
        playingState,
        velocityX,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerStarted;
}

class MatchDiffInfoPlayerJumped extends MatchDiffInfoEntity {
  final String userId;
  final double velocityY;

  MatchDiffInfoPlayerJumped(this.userId, this.velocityY);

  factory MatchDiffInfoPlayerJumped.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerJumped(
        json['userId'] as String,
        json['velocityY'] as double,
      );

  @override
  List<Object?> get props => [
        userId,
        velocityY,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerJumped;
}

class MatchDiffInfoPlayerMoved extends MatchDiffInfoEntity {
  final String userId;
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;

  MatchDiffInfoPlayerMoved(
    this.userId,
    this.x,
    this.y,
    this.velocityX,
    this.velocityY,
  );

  factory MatchDiffInfoPlayerMoved.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerMoved(
        json['userId'] as String,
        json['x'] as double,
        json['y'] as double,
        json['velocityX'] as double,
        json['velocityY'] as double,
      );

  @override
  List<Object?> get props => [
        userId,
        x,
        y,
        velocityX,
        velocityY,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerMoved;
}

class MatchDiffInfoPlayerDied extends MatchDiffInfoEntity {
  final String userId;
  final double x;
  final double y;
  final double spawnsAgainIn;
  final double newX;
  final double newY;
  final int diedCount;

  MatchDiffInfoPlayerDied(
    this.userId,
    this.x,
    this.y,
    this.spawnsAgainIn,
    this.newX,
    this.newY,
    this.diedCount,
  );

  factory MatchDiffInfoPlayerDied.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerDied(
        json['userId'] as String,
        json['x'] as double,
        json['y'] as double,
        (json['spawnsAgainIn'] as num) / 1000,
        json['newX'] as double,
        json['newY'] as double,
        json['diedCount'] as int,
      );

  @override
  List<Object?> get props => [
        userId,
        x,
        y,
        spawnsAgainIn,
        newX,
        newY,
        diedCount,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerDied;
}

class MatchDiffInfoPlayerScored extends MatchDiffInfoEntity {
  final String userId;
  final int score;

  MatchDiffInfoPlayerScored(this.userId, this.score);

  factory MatchDiffInfoPlayerScored.fromJson(Map<String, dynamic> json) =>
      MatchDiffInfoPlayerScored(
        json['userId'] as String,
        json['score'] as int,
      );

  @override
  List<Object?> get props => [
        userId,
        score,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerScored;
}

class MatchDiffInfoPlayerSpawnTimeDecreased extends MatchDiffInfoEntity {
  final String userId;
  final double spawnsAgainIn;

  MatchDiffInfoPlayerSpawnTimeDecreased(this.userId, this.spawnsAgainIn);

  factory MatchDiffInfoPlayerSpawnTimeDecreased.fromJson(
          Map<String, dynamic> json) =>
      MatchDiffInfoPlayerSpawnTimeDecreased(
        json['userId'] as String,
        (json['spawnsAgainIn'] as num) / 1000,
      );

  @override
  List<Object?> get props => [
        userId,
        spawnsAgainIn,
      ];

  @override
  MatchDiffCode get diffCode => MatchDiffCode.playerSpawnTimeDecreased;
}
