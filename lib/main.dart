import 'package:device_preview/device_preview.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/app_routes.dart';
import 'presentation/app_style.dart';
import 'presentation/bloc/game/game_cubit.dart';

void main() async {
  await setupServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const MyApp(),
  ));
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
      lazy: false,
      child: MaterialApp.router(
        routerConfig: AppRoutes.router,
        title: 'Flappy Dash',
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          fontFamily: 'Chewy',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.blueColor,
          ),
        ),
      ),
    );
  }
}
