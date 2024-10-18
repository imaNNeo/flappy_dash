import 'dart:ui';

import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiplayerDiedOverlayWidget extends StatelessWidget {
  const MultiplayerDiedOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.spawnsAgainAt != null) {
          final secondsLeft =
              state.spawnsAgainAt!.difference(DateTime.now()).inSeconds;

          if (secondsLeft <= 0 && state.currentPlayingState.isGameOver) {
            context.read<MultiplayerCubit>().dispatchPlayerIsIdleEvent();
            context.read<GameCubit>().continueGame();
          }
        }
      },
      builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.multiplayerDiedMessage?.header ?? '',
                    style: const TextStyle(
                      color: Color(0xFFFFCA00),
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state.multiplayerDiedMessage
                            ?.getBody(state.spawnRemainingSeconds) ??
                        '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}