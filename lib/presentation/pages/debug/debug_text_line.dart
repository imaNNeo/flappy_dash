import 'package:flappy_dash/domain/entities/styled_text.dart';
import 'package:flutter/material.dart';

class DebugTextLine extends StatelessWidget {
  final List<StyledText> words;

  const DebugTextLine({
    super.key,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: words
            .map(
              (word) => TextSpan(
            text: word.text,
            style: TextStyle(
              color: word.color,
              fontSize: 12,
              fontWeight: word.isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'RobotoMono',
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}