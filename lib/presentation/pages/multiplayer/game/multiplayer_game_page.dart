import 'package:flame/game.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/singleplayer/singleplayer_game_cubit.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/presentation_utils.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/multiplayer_scoreboard.dart';
import 'package:flappy_dash/presentation/widget/tap_to_play.dart';
import 'package:flappy_dash/presentation/widget/top_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'parts/multiplayer_died_overlay.dart';

class MultiPlayerGamePage extends StatefulWidget {
  const MultiPlayerGamePage({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  State<MultiPlayerGamePage> createState() => _MultiPlayerGamePageState();
}

class _MultiPlayerGamePageState extends State<MultiPlayerGamePage> {
  late FlappyDashGame _flappyDashGame;

  late SingleplayerGameCubit singleplayerCubit;
  late MultiplayerCubit multiplayerCubit;
  late LeaderboardCubit leaderboardCubit;

  DashType get dashType {
    final userId = multiplayerCubit.state.currentUserId;
    return DashType.fromUserId(userId);
  }

  @override
  void initState() {
    singleplayerCubit = BlocProvider.of<SingleplayerGameCubit>(context);
    multiplayerCubit = BlocProvider.of<MultiplayerCubit>(context);
    leaderboardCubit = BlocProvider.of<LeaderboardCubit>(context);
    _flappyDashGame = FlappyDashGame(
      const MultiplayerGameMode(),
      singleplayerCubit,
      multiplayerCubit,
      leaderboardCubit,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MultiplayerCubit, MultiplayerState>(
      listenWhen: (previous, current) =>
          previous.matchState?.currentPhase != current.matchState?.currentPhase,
      listener: (context, state) {
        if (state.matchState != null &&
            state.matchState!.currentPhase == MatchPhase.finished) {
          _onGameFinished();
        }
      },
      child: BlocBuilder<MultiplayerCubit, MultiplayerState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                GameWidget(
                  game: _flappyDashGame,
                  backgroundBuilder: (_) {
                    return Container(
                      color: AppColors.backgroundColor,
                    );
                  },
                ),
                if (state.currentPlayingState.isGameOver)
                  const MultiplayerDiedOverlayWidget(),
                if (state.currentPlayingState.isIdle)
                  const Align(
                    alignment: Alignment(0, 0.2),
                    child: TapToPlay(),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      TopScore(
                        currentScore: state.currentScore,
                        customColor: AppColors.getDashColor(
                          dashType,
                        ),
                      ),
                      _RemainingPlayingTimer(),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: PresentationConstants.defaultPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GameBackButton(),
                              Expanded(
                                child: Container(
                                  height: 0,
                                ),
                              ),
                              const _ScoreboardSection(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    multiplayerCubit.stopPlaying(widget.matchId);
    super.dispose();
  }

  void _onGameFinished() {
    final matchId = multiplayerCubit.state.matchId;
    context.go('/multi_player/$matchId/result');
  }
}

class _RemainingPlayingTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        return Text(
          PresentationUtils.formatSeconds(
            state.matchPlayingRemainingSeconds,
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            height: 1,
          ),
        );
      },
    );
  }
}

class _ScoreboardSection extends StatelessWidget {
  const _ScoreboardSection();

  List<MultiplayerScore> getSortedScores(MultiplayerState state) {
    final sortedPlayers =
        state.matchState!.players.entries.map((e) => e.value).toList();
    sortedPlayers.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return sortedPlayers.asMap().entries.map((e) {
      final rank = e.key + 1;
      final player = e.value;
      final dashType = DashType.fromUserId(
        player.userId,
      );
      return MultiplayerScore(
        playerId: player.userId,
        score: player.score,
        displayName: player.displayName,
        dashType: dashType,
        rank: rank,
        isMe: player.userId == state.currentUserId,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        if (state.matchState == null) {
          return const SizedBox();
        }

        return MultiplayerScoreBoard(
          scores: getSortedScores(state),
        );
      },
    );
  }
}
