import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class OutlinedTextComponent extends PositionComponent {
  OutlinedTextComponent({
    super.position,
    required String text,
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontFamily: 'Chewy',
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
  })  : _text = text,
        super();

  String _text;

  String get text => _text;

  set text(String newText) {
    _text = newText;
    _textComponent1.text = newText;
    _textComponent2.text = newText;
  }

  final TextStyle textStyle;
  final double strokeWidth;
  final Color strokeColor;

  late TextComponent _textComponent1, _textComponent2;

  @override
  void onLoad() {
    super.onLoad();
    add(_textComponent1 = TextComponent(
      text: text,
      anchor: Anchor.bottomCenter,
      textRenderer: TextPaint(
        style: textStyle.copyWith(
          color: null,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = strokeColor,
        ),
      ),
      children: [
        _textComponent2 = TextComponent(
          text: text,
          textRenderer: TextPaint(
            style: textStyle,
          ),
        ),
      ],
    ));
  }
}
