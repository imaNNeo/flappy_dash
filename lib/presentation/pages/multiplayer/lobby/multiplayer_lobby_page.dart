import 'dart:async';
import 'dart:math';

import 'package:flappy_dash/domain/app_constants.dart';
import 'package:flappy_dash/domain/entities/match_event.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/nickname_dialog.dart';
import 'package:flappy_dash/presentation/dialogs/share_lobby_dialog.dart';
import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/game/parts/last_match_winner_widget.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/lobby/parts/auto_jump_widget.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

part 'parts/pending_match_box.dart';

class MultiPlayerLobbyPage extends StatefulWidget {
  const MultiPlayerLobbyPage({super.key, required this.matchId});

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
    _multiplayerCubit.refreshLastMatchOverview();
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
    final shortLandscape = context.isShortLandscape;
    final boxHorizontalPadding = switch (screenSize) {
      ScreenSize.extraSmall => 10.0,
      ScreenSize.small => 12.0,
      ScreenSize.medium => 22.0,
      ScreenSize.large || ScreenSize.extraLarge => 28.0,
    };
    final boxHorizontalMargin = switch (screenSize) {
      ScreenSize.extraSmall => 8.0,
      ScreenSize.small => 12.0,
      ScreenSize.medium => 22.0,
      ScreenSize.large || ScreenSize.extraLarge => 48.0,
    };
    final lastWinnerBadgeHeight = switch (screenSize) {
      ScreenSize.extraSmall => 46.0,
      ScreenSize.small => 54.0,
      ScreenSize.medium => 58.0,
      ScreenSize.large || ScreenSize.extraLarge => 64.0,
    };

    final topBar = Padding(
      padding: const EdgeInsets.only(
        top: PresentationConstants.defaultPadding / 2,
        right: PresentationConstants.defaultPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const GameBackButton(),
          const Spacer(),
          const ProfileOverlay(),
        ],
      ),
    );

    final title = FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        // Room for the "Multi Player" text that hangs below the title.
        padding: EdgeInsets.only(
          bottom: switch (screenSize) {
            ScreenSize.extraSmall => 22.0,
            ScreenSize.small => 26.0,
            ScreenSize.medium => 30.0,
            ScreenSize.large || ScreenSize.extraLarge => 44.0,
          },
          right: 24,
        ),
        child: GameTitle(screenSize: screenSize, showMultiplayerText: true),
      ),
    );

    final box = PendingMatchBox(
      horizontalPadding: boxHorizontalPadding,
      lastWinnerHeight: lastWinnerBadgeHeight,
      margin: EdgeInsets.zero,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BlurredBackground(),
          SafeArea(
            child: shortLandscape
                // Wide and short: title on the left, lobby on the right, so
                // the JOIN button is never pushed off the bottom.
                ? Column(
                    children: [
                      topBar,
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: title,
                                        ),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: WatchOnYoutubeWidget(
                                        screenSize: screenSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 560,
                                    ),
                                    child: box,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      topBar,
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: title,
                        ),
                      ),
                      SizedBox(height: lastWinnerBadgeHeight * 0.2),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: boxHorizontalMargin,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: screenSize == ScreenSize.extraLarge
                                  ? const BoxConstraints(
                                      maxWidth: 900,
                                      maxHeight: 680,
                                    )
                                  : const BoxConstraints(
                                      maxWidth: 680,
                                      maxHeight: 560,
                                    ),
                              child: box,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: WatchOnYoutubeWidget(screenSize: screenSize),
                      ),
                      const SizedBox(height: 12),
                    ],
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
