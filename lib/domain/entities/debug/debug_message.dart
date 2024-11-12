import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/dispatching_match_event.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/domain/entities/styled_text.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';

sealed class DebugMessage {
  Color get incomingEventColor => Colors.green;

  Color get outgoingEventColor => Colors.blue;

  Color get functionCallColor => Colors.orange;

  Color get normalColor => Colors.white;

  Color get valueColor => Colors.purpleAccent;

  final _timestamp = DateTime.now();

  String get time =>
      '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}:${_timestamp.second.toString().padLeft(2, '0')}';

  List<StyledText> toDebugMessage(String currentUserId);
}

class DebugIncomingEvent extends DebugMessage {
  final MatchEvent event;

  DebugIncomingEvent(this.event);

  @override
  List<StyledText> toDebugMessage(String currentUserId) {
    final isMe = event.sender?.userId == currentUserId;
    final senderColor = currentUserId.isNullOrBlank
        ? incomingEventColor
        : AppColors.getDashColor(
            DashType.fromUserId(currentUserId),
          );
    return [
      StyledText(time, normalColor),
      StyledText(' ↓ ', incomingEventColor, isBold: true),
      StyledText('${event.runtimeType} ', incomingEventColor, isBold: true),
      StyledText(
        'from: ',
        normalColor,
        isBold: true,
      ),
      StyledText(
        '${event.sender?.userId.split('-')[0]} ${isMe ? 'me' : ''}',
        senderColor,
        isBold: true,
      ),
    ];
  }
}

class DebugDispatchingEvent extends DebugMessage {
  final DispatchingMatchEvent event;

  DebugDispatchingEvent(this.event);

  @override
  List<StyledText> toDebugMessage(String currentUserId) {
    final extraInfo = event.debugExtraInfo();
    return [
      StyledText(time, normalColor),
      StyledText(' ↑ ', outgoingEventColor, isBold: true),
      StyledText('${event.runtimeType} ', outgoingEventColor, isBold: true),
      if (extraInfo.isNotNullOrBlank)
        StyledText(
          ' - ${event.debugExtraInfo()} ',
          outgoingEventColor,
          isBold: false,
        ),
    ];
  }
}

class DebugFunctionCallEvent extends DebugMessage {
  final String className;
  final String functionName;
  final Map<String, String> info;

  DebugFunctionCallEvent(
    this.className,
    this.functionName,
    this.info,
  );

  @override
  List<StyledText> toDebugMessage(String currentUserId) => [
        StyledText(time, normalColor),
        StyledText(' - ', functionCallColor, isBold: true),
        StyledText('$className.$functionName', functionCallColor, isBold: true),
        StyledText(
          ' - (${info.entries.map((e) => '${e.key}: ${e.value}').join(', ')})',
          functionCallColor,
          isBold: false,
        ),
      ];
}
