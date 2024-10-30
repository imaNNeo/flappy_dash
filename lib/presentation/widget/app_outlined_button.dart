import 'package:flutter/material.dart';

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    this.onPressed,
    this.strokeColor = const Color(0xFFCACACA),
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;
  final VoidCallback? onPressed;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding,
        side: BorderSide(
          color: strokeColor,
          width: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: child,
    );
  }
}
