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

/// Fills the space around the game on screens that don't have the game's
/// aspect ratio (desktop, tablets, phones in landscape) with the blurred
/// scenery instead of a flat color, so the game blends into the page.
class GameLetterboxBackground extends StatelessWidget {
  const GameLetterboxBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        BlurredBackground(),
        ColoredBox(color: Color(0x660B3B3C)),
      ],
    );
  }
}
