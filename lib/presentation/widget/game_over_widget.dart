import 'dart:ui';

import 'package:flappy_dash/presentation/bloc/singleplayer/singleplayer_game_cubit.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleplayerGameCubit, SingleplayerGameState>(
      builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black54,
            child: SafeArea(
              minimum: const EdgeInsets.all(24),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'GAME OVER!',
                        style: TextStyle(
                          color: Color(0xFFFFCA00),
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Score: ${state.currentScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 60),
                      BigButton(
                        strokeColor: Colors.white,
                        bgColor: AppColors.blueButtonBgColor,
                        onPressed: () {
                          context.read<SingleplayerGameCubit>().restartGame();
                        },
                        child: const Text(
                          'PLAY AGAIN!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
