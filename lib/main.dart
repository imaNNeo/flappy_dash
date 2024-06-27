import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_helper.dart';
import 'cubit/game/game_cubit.dart';
import 'pages/main_page.dart';

AudioHelper audioHelper = AudioHelper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await audioHelper.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(
        audioHelper,
      ),
      child: MaterialApp(
        home: const MainPage(),
        theme: ThemeData(
          fontFamily: 'Chewy',
          colorSchemeSeed: const Color(0xFF30CBF9),
        ),
      ),
    );
  }
}
