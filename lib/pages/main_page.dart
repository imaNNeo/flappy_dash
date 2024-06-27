import 'package:flame/game.dart';
import 'package:flappy_dash/cubit/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../flappy_dash_game.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlappyDashGame _game;

  @override
  void initState() {
    _game = FlappyDashGame(
      context.read<GameCubit>(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: _game,
            backgroundBuilder: (context) {
              return Container(
                color: Colors.grey,
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 38.0),
              child: BlocBuilder<GameCubit, GameState>(
                builder: (context, state) {
                  return Text(
                    state.currentScore.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
