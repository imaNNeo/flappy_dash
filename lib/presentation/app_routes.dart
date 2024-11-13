import 'package:flappy_dash/presentation/pages/home/home_page.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/game/multiplayer_game_page.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/lobby/multiplayer_lobby_page.dart';
import 'package:flappy_dash/presentation/pages/singleplayer/singleplayer_game_page.dart';
import 'package:flappy_dash/presentation/pages/splash/cubit/splash_cubit.dart';
import 'package:flappy_dash/presentation/pages/splash/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pages/multiplayer/result/match_result_page.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters['redirectTo'];
          return SplashPage(redirectTo: redirectTo);
        },
      ),
      GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'single_player',
              builder: (context, state) => const SinglePlayerGamePage(),
            ),
            GoRoute(
              path: 'lobby/:matchId',
              builder: (context, state) {
                return MultiPlayerLobbyPage(
                  matchId: state.pathParameters['matchId']!,
                );
              },
            ),
            GoRoute(
                path: 'multi_player/:matchId',
                builder: (context, state) {
                  return MultiPlayerGamePage(
                    matchId: state.pathParameters['matchId']!,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'result',
                    builder: (context, state) {
                      return MatchResultPage(
                        matchId: state.pathParameters['matchId']!,
                      );
                    },
                  ),
                ]),
          ]),
    ],
    redirect: (context, state) {
      final splashCubit = context.read<SplashCubit>();
      final splashInitialized = splashCubit.state.isSplashInitialized;
      if (!splashInitialized && state.uri.path != '/splash') {
        final encodedPath = Uri.encodeComponent(state.uri.toString());
        return '/splash?redirectTo=$encodedPath';
      }
      return null;
    },
  );
}
