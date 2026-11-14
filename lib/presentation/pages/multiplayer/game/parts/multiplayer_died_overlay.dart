import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flappy_dash/presentation/widget/game_over_backdrop.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiplayerDiedOverlayWidget extends StatelessWidget {
  const MultiplayerDiedOverlayWidget({super.key, this.rehearsal = false});

  /// See [GameOverBackdrop.rehearsal].
  final bool rehearsal;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      buildWhen: (previous, current) =>
          previous.multiplayerDiedMessage != current.multiplayerDiedMessage ||
          previous.spawnRemainingSeconds != current.spawnRemainingSeconds,
      builder: (context, state) {
        return GameOverBackdrop(
          rehearsal: rehearsal,
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                state.multiplayerDiedMessage?.getBody(
                      state.spawnRemainingSeconds,
                    ) ??
                    '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
