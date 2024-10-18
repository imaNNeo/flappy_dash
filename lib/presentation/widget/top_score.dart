import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';

class TopScore extends StatelessWidget {
  const TopScore({
    super.key,
    this.customColor,
    required this.currentScore,
  });

  final Color? customColor;
  final int currentScore;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 38,
    );
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: customColor == null
            ? Text(
                currentScore.toString(),
                style: style,
              )
            : OutlineText(
                Text(
                  currentScore.toString(),
                  style: style.copyWith(
                    color: customColor!,
                  ),
                ),
                strokeWidth: 6,
              ),
      ),
    );
  }
}
