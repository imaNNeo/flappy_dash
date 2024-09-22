import 'package:flutter/material.dart';

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/blurred_background.png',
      fit: BoxFit.cover,
    );
  }
}
