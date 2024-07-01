import 'package:flame/game.dart';
import 'package:flappy_dash/flappy_dash_game.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FlappyDashGame _flappyDashGame;

  @override
  void initState() {
    _flappyDashGame = FlappyDashGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _flappyDashGame,
      ),
    );
  }
}
