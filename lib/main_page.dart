import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'flappy_dash_game.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlappyDashGame _game;

  @override
  void initState() {
    _game = FlappyDashGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
    );
  }
}
