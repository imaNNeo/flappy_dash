import 'package:flame/game.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/game_mode.dart';
import 'package:flappy_dash/domain/entities/match_phase.dart';
import 'package:flappy_dash/domain/entities/playing_state.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/flappy_dash_game.dart';
import 'package:flappy_dash/presentation/presentation_utils.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/game_over_widget.dart';
import 'package:flappy_dash/presentation/widget/multiplayer_scoreboard.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flappy_dash/presentation/widget/tap_to_play.dart';
import 'package:flappy_dash/presentation/widget/top_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MultiPlayerGamePage extends StatefulWidget {
  const MultiPlayerGamePage({super.key});

  @override
  State<MultiPlayerGamePage> createState() => _MultiPlayerGamePageState();
}

class _MultiPlayerGamePageState extends State<MultiPlayerGamePage> {
  late FlappyDashGame _flappyDashGame;

  late GameCubit gameCubit;
  late MultiplayerCubit multiplayerCubit;
  late LeaderboardCubit leaderboardCubit;

  PlayingState? _latestState;

  DashType get dashType {
    final userId = multiplayerCubit.state.currentUserId;
    return DashType.fromUserId(userId);
  }

  @override
  void initState() {
    gameCubit = BlocProvider.of<GameCubit>(context);
    gameCubit.initialize(const MultiplayerGameMode());
    multiplayerCubit = BlocProvider.of<MultiplayerCubit>(context);
    leaderboardCubit = BlocProvider.of<LeaderboardCubit>(context);
    _flappyDashGame = FlappyDashGame(
      gameCubit,
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
      child: BlocConsumer<GameCubit, GameState>(
        listener: (context, state) {
          if (state.currentPlayingState.isIdle &&
              _latestState == PlayingState.gameOver) {
            setState(() {
              _flappyDashGame = FlappyDashGame(
                gameCubit,
                multiplayerCubit,
                leaderboardCubit,
              );
            });
          }

          _latestState = state.currentPlayingState;
        },
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
                  const GameOverWidget(),
                if (state.currentPlayingState.isIdle)
                  const Align(
                    alignment: Alignment(0, 0.2),
                    child: TapToPlay(),
                  ),
                if (state.currentPlayingState.isNotGameOver)
                  SafeArea(
                    child: Column(
                      children: [
                        TopScore(
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
                        right: PresentationConstants.defaultPadding,
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
                              const ProfileOverlay(),
                            ],
                          ),
                          const _ScoreboardSection(),
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
    multiplayerCubit.stopPlaying();
    gameCubit.stopPlaying();
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
