import 'package:flame/game.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/widget/game_over_widget.dart';
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
          GameWidget(
            game: _flappyDashGame,
            errorBuilder: (context, error) {
              return const Center(
                child: Text('Error loading game'),
              );
            },
          ),
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
                  const Align(
                    alignment: Alignment.topRight,
                    child: _OtherDashesWidget(),
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

class _OtherDashesWidget extends StatelessWidget {
  const _OtherDashesWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        final userItems = <(bool isMe, String name, int score)>[];
        userItems.addAll(
          state.otherDashes.entries.map(
            (entry) {
              final otherDash = entry.value;
              return (false, otherDash.name, otherDash.score);
            },
          ),
        );
        userItems.add((true, 'You', state.currentScore));
        userItems.sort((a, b) => b.$3.compareTo(a.$3));


        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: userItems.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final (isMe, name, score) = entry.value;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 240, maxWidth: 240),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        color: Colors.black12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${index + 1}.",
                            style: const TextStyle(
                              color: Color(0xFFE76802),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                          Expanded(child: Container()),
                          Text(
                            score.toString(),
                            style: const TextStyle(
                              color: Color(0xFF2387FC),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}
