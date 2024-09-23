import 'package:flame/game.dart';
import 'package:flappy_dash/presentation/dialogs/app_dialogs.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/widget/best_score_overlay.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/game/game_cubit.dart';
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

  late GameCubit gameCubit;

  PlayingState? _latestState;

  @override
  void initState() {
    gameCubit = BlocProvider.of<GameCubit>(context);
    _flappyDashGame = FlappyDashGame(gameCubit);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.currentPlayingState.isIdle &&
            _latestState == PlayingState.gameOver) {
          setState(() {
            _flappyDashGame = FlappyDashGame(gameCubit);
          });
        }

        _latestState = state.currentPlayingState;
      },
      builder: (context, state) {
        return Scaffold(
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
              if (state.currentPlayingState.isNotGameOver) const TopScore(),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    right: 16.0,
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
                              onTap: () => AppDialogs.showLeaderboard(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
