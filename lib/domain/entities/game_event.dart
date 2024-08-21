import 'dart:convert';

import 'package:equatable/equatable.dart';

sealed class GameEvent with EquatableMixin {
  const GameEvent();

  List<int> toBytes();

  abstract final int opCode;

  factory GameEvent.fromBytes(int opCode, List<int> data) {
    if (opCode == 0) {
      return StartGameEventData.fromBytes(data);
    } else if (opCode == 1) {
      return LetsTryAgainEventData.fromBytes(data);
    } else if (opCode == 2) {
      return JumpEventData.fromBytes(data);
    } else if (opCode == 3) {
      return CorrectPositionEventData.fromBytes(data);
    } else if (opCode == 4) {
      return UpdateScoreEventData.fromBytes(data);
    } else if (opCode == 5) {
      return LooseEventData.fromBytes(data);
    }
    throw Exception('Unknown opCode: $opCode');
  }
}

class StartGameEventData extends GameEvent with EquatableMixin {
  final double x;
  final double y;
  final int score;

  @override
  final int opCode = 0;

  StartGameEventData({
    required this.x,
    required this.y,
    required this.score,
  });

  @override
  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
      'score': score,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory StartGameEventData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return StartGameEventData(
      x: json['x'],
      y: json['y'],
      score: json['score'],
    );
  }

  @override
  List<Object?> get props => [
    x,
    y,
    score,
  ];
}

class LetsTryAgainEventData extends GameEvent with EquatableMixin {
  final double x;
  final double y;
  final int score;

  @override
  final int opCode = 1;

  LetsTryAgainEventData({
    required this.x,
    required this.y,
    required this.score,
  });

  @override
  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
      'score': score,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory LetsTryAgainEventData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return LetsTryAgainEventData(
      x: json['x'],
      y: json['y'],
      score: json['score'],
    );
  }

  @override
  List<Object?> get props => [
    x,
    y,
    score,
  ];
}

class JumpEventData extends GameEvent with EquatableMixin {
  final double x;
  final double y;

  @override
  final int opCode = 2;

  JumpEventData({required this.x, required this.y});

  @override
  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory JumpEventData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return JumpEventData(
      x: json['x'],
      y: json['y'],
    );
  }

  @override
  List<Object?> get props => [x, y];
}

class CorrectPositionEventData extends GameEvent with EquatableMixin {
  final double x;
  final double y;

  @override
  final int opCode = 3;

  CorrectPositionEventData({required this.x, required this.y});

  @override
  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory CorrectPositionEventData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return CorrectPositionEventData(
      x: json['x'],
      y: json['y'],
    );
  }

  @override
  List<Object?> get props => [x, y];
}

class UpdateScoreEventData extends GameEvent with EquatableMixin {
  final int score;

  @override
  final int opCode = 4;

  UpdateScoreEventData({required this.score});

  @override
  List<int> toBytes() {
    return [score];
  }

  factory UpdateScoreEventData.fromBytes(List<int> data) {
    return UpdateScoreEventData(score: data[0]);
  }

  @override
  List<Object?> get props => [score];
}

class LooseEventData extends GameEvent with EquatableMixin {
  final double x;
  final double y;

  @override
  final int opCode = 5;

  LooseEventData({required this.x, required this.y});

  @override
  List<int> toBytes() {
    final json = {
      'x': x,
      'y': y,
    };
    final jsonData = jsonEncode(json);
    return utf8.encode(jsonData);
  }

  factory LooseEventData.fromBytes(List<int> data) {
    final jsonData = utf8.decode(data);
    final json = jsonDecode(jsonData);
    return LooseEventData(
      x: json['x'],
      y: json['y'],
    );
  }

  @override
  List<Object?> get props => [x, y];
}
