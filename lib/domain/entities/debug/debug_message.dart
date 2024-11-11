import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/styled_text.dart';
import 'package:flutter/material.dart';

sealed class DebugMessage {
  Color get incomingEventColor => Colors.green;

  Color get outgoingEventColor => Colors.blue;

  Color get normalColor => Colors.white;

  Color get valueColor => Colors.purpleAccent;

  final _timestamp = DateTime.now();

  String get time =>
      '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}:${_timestamp.second.toString().padLeft(2, '0')}';

  List<StyledText> toDebugMessage();
}

class DebugIncomingEvent extends DebugMessage {
  final MatchEvent event;

  DebugIncomingEvent(this.event);

  @override
  List<StyledText> toDebugMessage() => [
        StyledText(time, normalColor),
        StyledText(' ↓ ', incomingEventColor, isBold: true),
        StyledText('${event.runtimeType} ', incomingEventColor, isBold: true),
        StyledText('from: ', normalColor),
        StyledText('${event.sender?.userId.split('-')[0]} ', valueColor),
      ];
}

class DebugDispatchingEvent extends DebugMessage {
  final DispatchingMatchEvent event;

  DebugDispatchingEvent(this.event);

  @override
  List<StyledText> toDebugMessage() => [
        StyledText(time, normalColor),
        StyledText(' ↑ ', outgoingEventColor, isBold: true),
        StyledText('${event.runtimeType} ', outgoingEventColor, isBold: true),
      ];
}
