import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/cubit/game/game_cubit.dart';
import 'package:flutter/material.dart';

class GuideTexts extends PositionComponent
    with FlameBlocListenable<GameCubit, GameState> {
  GuideTexts();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(
      TextComponent(
        text: 'TAP TO START',
        position: Vector2(0, 260),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF2388FA),
            fontSize: 36,
            fontFamily: 'Chewy',
          ),
        ),
        children: [
          ScaleEffect.to(
            Vector2.all(1.2),
            EffectController(
              duration: 0.5,
              infinite: true,
              alternate: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onNewState(GameState state) {
    super.onNewState(state);
    if (state.playingState.isPlaying) {
      removeFromParent();
    }
  }
}
