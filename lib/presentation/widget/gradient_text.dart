import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OutlineText(
          Text(text, style: style),
          strokeColor: Colors.white,
          strokeWidth: 4,
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(text, style: style),
        ),
      ],
    );
  }
}
