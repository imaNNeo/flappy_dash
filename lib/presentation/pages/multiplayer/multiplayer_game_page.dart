import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiPlayerGamePage extends StatefulWidget {
  const MultiPlayerGamePage({super.key});

  @override
  State<MultiPlayerGamePage> createState() => _MultiPlayerGamePageState();
}

class _MultiPlayerGamePageState extends State<MultiPlayerGamePage> {
  late final GameCubit gameCubit;

  @override
  void initState() {
    gameCubit = BlocProvider.of<GameCubit>(context);
    gameCubit.initialize(const MultiplayerGameMode());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Text('Multiplayer Game Page'),
      ),
    );
  }
}
