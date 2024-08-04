import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopScore extends StatelessWidget {
  const TopScore({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(
              state.currentScore.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 38,
              ),
            ),
          ),
        );
      },
    );
  }
}
