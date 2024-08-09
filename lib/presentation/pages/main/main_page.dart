import 'package:flame/game.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/widget/game_over_widget.dart';
import 'package:flappy_dash/presentation/widget/leaderboard_top_n.dart';
import 'package:flappy_dash/presentation/widget/tap_to_play.dart';
import 'package:flappy_dash/presentation/widget/top_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlappyDashGame _flappyDashGame;

  late GameCubit gameCubit;

  PlayingState? _latestState;

  @override
  void initState() {
    gameCubit = BlocProvider.of<GameCubit>(context);
    _flappyDashGame = FlappyDashGame(gameCubit);
    gameCubit.onPageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _flappyDashGame),
          BlocConsumer<GameCubit, GameState>(
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
              return Stack(
                children: [
                  if (state.currentPlayingState.isGameOver)
                    const GameOverWidget(),
                  if (state.currentPlayingState.isIdle)
                    const Align(
                      alignment: Alignment(0, 0.2),
                      child: TapToPlay(),
                    ),
                  if (state.currentPlayingState.isNotGameOver) const TopScore(),
                  if (state.leaderboard != null)
                    Align(
                      alignment: Alignment.topRight,
                      child: LeaderboardTopN(
                        leaderboard: state.leaderboard!,
                      ),
                    ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
