import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TopScore extends StatelessWidget {
  const TopScore({super.key, this.customColor, required this.currentScore});

  final Color? customColor;
  final int currentScore;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.black, fontSize: 38);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        // Each new score pops in big and settles with a wobble.
        child:
            (customColor == null
                    ? Text(currentScore.toString(), style: style)
                    : OutlineText(
                        Text(
                          currentScore.toString(),
                          style: style.copyWith(color: customColor!),
                        ),
                        strokeWidth: 6,
                      ))
                .animate(key: ValueKey(currentScore))
                .scale(
                  begin: Offset(
                    currentScore == 0 ? 1 : 1.6,
                    currentScore == 0 ? 1 : 1.6,
                  ),
                  end: const Offset(1, 1),
                  duration: 450.ms,
                  curve: Curves.elasticOut,
                )
                .rotate(
                  begin: currentScore == 0 ? 0 : -0.04,
                  end: 0,
                  duration: 450.ms,
                  curve: Curves.elasticOut,
                ),
      ),
    );
  }
}
