import 'dart:async';

import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/presentation_utils.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/dash_player_box.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/game_title.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flappy_dash/presentation/widget/transparent_content_box.dart';
import 'package:flappy_dash/presentation/widget/watch_on_youtube_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'parts/pending_match_box.dart';

class MultiPlayerLobbyPage extends StatefulWidget {
  const MultiPlayerLobbyPage({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  State<MultiPlayerLobbyPage> createState() =>
      _MultiPlayerLobbyPageContentState();
}

class _MultiPlayerLobbyPageContentState extends State<MultiPlayerLobbyPage> {
  late MultiplayerCubit _multiplayerCubit;

  late StreamSubscription<MatchEvent> _matchEventsSubscription;

  @override
  void initState() {
    _multiplayerCubit = context.read<MultiplayerCubit>();
    _multiplayerCubit.joinMatch(widget.matchId);
    _matchEventsSubscription = _multiplayerCubit.matchEvents.listen(
      _onMatchEvent,
    );
    super.initState();
  }

  void _onMatchEvent(MatchEvent event) {
    if (event is MatchStartedEvent) {
      if (!context.mounted) {
        return;
      }
      final matchId = _multiplayerCubit.state.matchId;
      context.go('/multi_player/$matchId');
    }
  }

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
    final appTitleTopPadding = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 92.0,
      ScreenSize.medium => 102.0,
      ScreenSize.large || ScreenSize.extraLarge => 18.0,
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
                  SizedBox(height: appTitleTopPadding),
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
                    const GameBackButton(),
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

  @override
  void dispose() {
    _multiplayerCubit.onLobbyClosed();
    _matchEventsSubscription.cancel();
    super.dispose();
  }
}
