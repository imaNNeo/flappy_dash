import 'package:flutter/material.dart';

class OutlineText extends StatelessWidget {
  final Text child;
  final double strokeWidth;
  final Color? strokeColor;
  final TextOverflow? overflow;

  const OutlineText(
      this.child, {
        super.key,
        this.strokeWidth = 2,
        this.strokeColor,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // stroke text
        Text(
          // need to set text scale if needed
          textScaler: child.textScaler,
          child.data!,
          style: TextStyle(
            fontSize: child.style?.fontSize,
            fontWeight: child.style?.fontWeight,
            foreground: Paint()
              ..color = strokeColor ?? Theme.of(context).shadowColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth,
            letterSpacing: child.style?.letterSpacing,
          ),
          // handle overflow
          overflow: overflow,
        ),
        // original text
        child
      ],
    );
  }
}