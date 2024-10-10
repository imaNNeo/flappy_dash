import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopScore extends StatelessWidget {
  const TopScore({
    super.key,
    this.customColor,
  });

  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        const style = TextStyle(
          color: Colors.black,
          fontSize: 38,
        );
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: customColor == null
                ? Text(
                    state.currentScore.toString(),
                    style: style,
                  )
                : OutlineText(
                    Text(
                      state.currentScore.toString(),
                      style: style.copyWith(
                        color: customColor!,
                      ),
                    ),
                    strokeWidth: 6,
                  ),
          ),
        );
      },
    );
  }
}
