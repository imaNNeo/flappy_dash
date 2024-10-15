import 'package:flappy_dash/presentation/pages/home/home_page.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/game/multiplayer_game_page.dart';
import 'package:flappy_dash/presentation/pages/multiplayer/lobby/multiplayer_lobby_page.dart';
import 'package:flappy_dash/presentation/pages/singleplayer/singleplayer_game_page.dart';
import 'package:flappy_dash/presentation/pages/splash/splash_page.dart';
import 'package:go_router/go_router.dart';

import 'pages/multiplayer/result/match_result_page.dart';

class AppRoutes {
  static GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
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
            builder: (context, state) => const MultiPlayerGamePage(),
            routes: [
              GoRoute(
                path: 'result',
                builder: (context, state) {
                  return MatchResultPage(
                    matchId: state.pathParameters['matchId']!,
                  );
                },
              ),
            ]
          ),
        ]
      ),
    ],
  );
}
