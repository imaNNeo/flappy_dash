import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/domain/repositories/settings_repository.dart';
import 'package:flappy_dash/presentation/bloc/settings/settings_cubit.dart';
import 'package:flappy_dash/presentation/pages/splash/cubit/splash_cubit.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'account/account_cubit.dart';
import 'leaderboard/leaderboard_cubit.dart';
import 'multiplayer/multiplayer_cubit.dart';
import 'multiplayer/ping/ping_cubit.dart';
import 'singleplayer/singleplayer_game_cubit.dart';

class AppBlocRegistry extends StatelessWidget {
  final Widget child;

  const AppBlocRegistry({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SingleplayerGameCubit(
            getIt.get<AudioHelper>(),
            getIt.get<GameRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => MultiplayerCubit(
            getIt.get<MultiplayerRepository>(),
            getIt.get<GameRepository>(),
            getIt.get<AudioHelper>(),
          ),
        ),
        BlocProvider(
          create: (context) => AccountCubit(
            getIt.get<GameRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => LeaderboardCubit(
            getIt.get<GameRepository>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PingCubit(
            getIt.get<MultiplayerRepository>(),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => SplashCubit(
            getIt.get<GameRepository>(),
            getIt.get<SettingsRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => SettingsCubit(
            getIt.get<SettingsRepository>(),
          ),
        )
      ],
      child: child,
    );
  }
}
