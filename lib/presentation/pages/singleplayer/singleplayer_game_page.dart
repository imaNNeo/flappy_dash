import 'package:flame/game.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/bloc/singleplayer/singleplayer_game_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/app_dialogs.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/widget/best_score_overlay.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/game_over_widget.dart';
import '../../widget/tap_to_play.dart';
import '../../widget/top_score.dart';

class SinglePlayerGamePage extends StatefulWidget {
  const SinglePlayerGamePage({super.key});

  @override
  State<SinglePlayerGamePage> createState() => _SinglePlayerGamePageState();
}

class _SinglePlayerGamePageState extends State<SinglePlayerGamePage> {
  late FlappyDashGame _flappyDashGame;

  late SingleplayerGameCubit gameCubit;
  late MultiplayerCubit multiplayerCubit;
  late LeaderboardCubit leaderboardCubit;

  PlayingState? _latestState;

  @override
  void initState() {
    gameCubit = BlocProvider.of<SingleplayerGameCubit>(context);
    multiplayerCubit = BlocProvider.of<MultiplayerCubit>(context);
    leaderboardCubit = BlocProvider.of<LeaderboardCubit>(context);
    _flappyDashGame = FlappyDashGame(
      const SinglePlayerGameMode(),
      gameCubit,
      multiplayerCubit,
      leaderboardCubit,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleplayerGameCubit, SingleplayerGameState>(
      listener: (context, state) {
        if (state.currentPlayingState.isIdle &&
            _latestState == PlayingState.gameOver) {
          setState(() {
            _flappyDashGame = FlappyDashGame(
              const SinglePlayerGameMode(),
              gameCubit,
              multiplayerCubit,
              leaderboardCubit,
            );
          });
        }

        _latestState = state.currentPlayingState;
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              GameWidget(
                game: _flappyDashGame,
                backgroundBuilder: (_) {
                  return Container(
                    color: AppColors.backgroundColor,
                  );
                },
              ),
              if (state.currentPlayingState.isGameOver) const GameOverWidget(),
              if (state.currentPlayingState.isIdle)
                const Align(
                  alignment: Alignment(0, 0.2),
                  child: TapToPlay(),
                ),
              if (state.currentPlayingState.isNotGameOver)
                SafeArea(
                  child: TopScore(
                    currentScore: state.currentScore,
                  ),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: PresentationConstants.defaultPadding,
                      right: PresentationConstants.defaultPadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GameBackButton(),
                        Expanded(
                          child: Container(
                            height: 0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const ProfileOverlay(),
                              const SizedBox(height: 8),
                              BestScoreOverlay(
                                onTap: () =>
                                    AppDialogs.showLeaderboard(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    gameCubit.stopPlaying();
    super.dispose();
  }
}
