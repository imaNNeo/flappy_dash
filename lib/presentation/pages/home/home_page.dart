import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/game_title.dart';
import 'package:flappy_dash/presentation/widget/gradient_text.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flappy_dash/presentation/widget/watch_on_youtube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'parts/single_player_button.dart';
part 'parts/multi_player_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BlurredBackground(),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),
                  const GameTitle(),
                  Expanded(child: Container()),
                  const SinglePlayerButton(),
                  const SizedBox(height: 18),
                  const MultiPlayerButton(),
                  const SizedBox(height: 8),
                  Expanded(child: Container()),
                  const WatchOnYoutubeWidget(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
