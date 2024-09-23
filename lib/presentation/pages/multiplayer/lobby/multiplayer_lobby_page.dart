import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/dash_player_box.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/game_title.dart';
import 'package:flappy_dash/presentation/widget/github_button.dart';
import 'package:flappy_dash/presentation/widget/transparent_content_box.dart';
import 'package:flappy_dash/presentation/widget/watch_on_youtube_widget.dart';
import 'package:flutter/material.dart';

part 'parts/pending_match_box.dart';

class MultiPlayerLobbyPage extends StatelessWidget {
  const MultiPlayerLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final boxVerticalSpacing = switch (screenSize) {
      ScreenSize.extraSmall => 18.0,
      ScreenSize.small => 28.0,
      ScreenSize.medium => 38.0,
      ScreenSize.large || ScreenSize.extraLarge => 48.0,
    };
    final boxHorizontalPadding = switch (screenSize) {
      ScreenSize.extraSmall => 10.0,
      ScreenSize.small => 12.0,
      ScreenSize.medium => 22.0,
      ScreenSize.large || ScreenSize.extraLarge => 28.0,
    };

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
                  GameTitle(
                    screenSize: screenSize,
                    showMultiplayerText: true,
                  ),
                  SizedBox(height: boxVerticalSpacing * 1.5),
                  Expanded(
                    child: PendingMatchBox(
                      horizontalPadding: boxHorizontalPadding,
                    ),
                  ),
                  SizedBox(height: boxVerticalSpacing),
                  WatchOnYoutubeWidget(screenSize: screenSize),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                const GameBackButton(),
                Expanded(child: Container(height: 0,)),
                GithubButton(
                  screenSize: screenSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
