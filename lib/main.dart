import 'package:flappy_dash/presentation/audio_helper.dart';
import 'package:flappy_dash/presentation/pages/splash/splash_page.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/game_repository.dart';
import 'presentation/bloc/game/game_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => GameCubit(
        getIt.get<AudioHelper>(),
        getIt.get<GameRepository>(),
      ),
      child: MaterialApp(
        title: 'Flappy Dash',
        theme: ThemeData(fontFamily: 'Chewy'),
        home: const SplashPage(),
      ),
    );
  }
}
