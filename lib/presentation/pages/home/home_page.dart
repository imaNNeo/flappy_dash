import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/game_title.dart';
import 'package:flappy_dash/presentation/widget/github_button.dart';
import 'package:flappy_dash/presentation/widget/gradient_text.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flappy_dash/presentation/widget/watch_on_youtube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

part 'parts/single_player_button.dart';

part 'parts/multi_player_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final titleBottomSpace = switch (screenSize) {
      ScreenSize.extraSmall => 16.0,
      ScreenSize.small => 24.0,
      ScreenSize.medium => 32.0,
      ScreenSize.large => 40.0,
      ScreenSize.extraLarge => 48.0,
    };
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                  GameTitle(screenSize: screenSize),
                  SizedBox(height: titleBottomSpace),
                  SinglePlayerButton(
                    onPressed: () => context.push('/single_player'),
                  ),
                  const SizedBox(height: 18),
                  MultiPlayerButton(
                    onPressed: () => context.push('/lobby:test-match-id'),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                  WatchOnYoutubeWidget(screenSize: screenSize),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: PresentationConstants.defaultPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GithubButton(
                      screenSize: screenSize,
                    ),
                    Expanded(
                        child: Container(
                      height: 0,
                    )),
                    const ProfileOverlay(),
                    const SizedBox(
                      width: PresentationConstants.defaultPadding,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
