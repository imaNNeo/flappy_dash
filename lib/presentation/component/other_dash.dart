import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flappy_dash/domain/entities/other_dash_entity.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';

class OtherDash extends PositionComponent
    with HasGameRef<FlappyDashGame>, FlameBlocReader<GameCubit, GameState> {
  OtherDash({
    required this.data,
  }) : super(
          position: Vector2(0, 0),
          size: Vector2.all(80.0),
          anchor: Anchor.center,
          priority: 10,
        );

  final OtherDashData data;
  late Sprite _dashSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _dashSprite = await Sprite.load(switch (data.userId.hashCode % 7) {
      0 => 'dash.png',
      1 => 'dash_black.png',
      2 => 'dash_cyan.png',
      3 => 'dash_green.png',
      4 => 'dash_orange.png',
      5 => 'dash_pink.png',
      6 => 'dash_yellow.png',
      _ => throw Exception('Invalid index'),
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (bloc.state.currentPlayingState.isNotPlaying) {
      return;
    }
    if (bloc.state.otherDashes.containsKey(data.userId)) {
      final otherDashData = bloc.state.otherDashes[data.userId]!;
      position = Vector2(otherDashData.x, otherDashData.y);
    }
    position.x %= bloc.state.gameConfig!.worldWidth;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _dashSprite.render(
      canvas,
      size: size,
    );
  }
}
