import 'dart:math';

import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/raw_scores_list_dialog.dart';
import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/app_outlined_button.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/dash_image.dart';
import 'package:flappy_dash/presentation/widget/error_retry_box.dart';
import 'package:flappy_dash/presentation/widget/game_back_button.dart';
import 'package:flappy_dash/presentation/widget/loading_overlay.dart';
import 'package:flappy_dash/presentation/widget/multiplayer_scoreboard.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus_dialog/share_plus_dialog.dart';

import 'cubit/match_result_cubit.dart';

part 'parts/current_player_score_box.dart';

part 'parts/large_rank_trophy.dart';

part 'parts/trophies_row.dart';

class MatchResultPage extends StatelessWidget {
  const MatchResultPage({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchResultCubit(
        gameRepository: getIt.get<MultiplayerRepository>(),
        matchId: matchId,
      ),
      child: _MatchResultPageContent(),
    );
  }
}

class _MatchResultPageContent extends StatefulWidget {
  @override
  State<_MatchResultPageContent> createState() =>
      _MatchResultPageContentState();
}

class _MatchResultPageContentState extends State<_MatchResultPageContent> {
  @override
  void initState() {
    context.read<MatchResultCubit>().pageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchResultCubit, MatchResultState>(
      listener: (context, state) {
        if (state.playAgainMatchId.isNotEmpty) {
          context.go('/lobby/${state.playAgainMatchId}');
        }

        if (state.playAgainError.isNotEmpty) {
          context.showToastError(state.error);
        }
      },
      builder: (context, state) {
        final screenSize = ScreenSize.fromContext(context);

        final topPadding = switch (screenSize) {
          ScreenSize.extraSmall || ScreenSize.small => 48.0,
          ScreenSize.medium => 48.0,
          ScreenSize.large || ScreenSize.extraLarge => 48.0,
        };

        final titleFontSize = switch (screenSize) {
          ScreenSize.extraSmall || ScreenSize.small => 58.0,
          ScreenSize.medium => 62.0,
          ScreenSize.large || ScreenSize.extraLarge => 68.0,
        };

        final bottomPadding = switch (screenSize) {
          ScreenSize.extraSmall || ScreenSize.small => 12.0,
          ScreenSize.medium => 24.0,
          ScreenSize.large || ScreenSize.extraLarge => 36.0,
        };
        ({
          int rank,
          String name,
          DashType dashType,
          int score,
        })? currentUserData;

        final myId = context.read<AccountCubit>().state.currentAccount?.user.id;

        if (state.matchResult != null) {
          final myScore = state.matchResult!.getMyScore(myId);
          if (myScore != null) {
            currentUserData = (
              rank: state.matchResult!.scores.indexOf(myScore) + 1,
              name: myScore.user.showingName,
              dashType: DashType.fromUserId(myScore.user.id),
              score: myScore.score,
            );
          }
        }

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (state.matchResult != null) ...[
                const BlurredBackground(),
                Container(color: AppColors.blackOverlay),
                Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: Row(
                          children: [
                            GameBackButton(
                              svgIcon: 'ic_home.svg',
                              overrideOnPressed: () => context.go('/'),
                            ),
                            Expanded(
                                child: Container(
                              height: 1,
                            )),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: currentUserData != null
                                  ? _CurrentPlayerScoreBox(
                                      data: currentUserData,
                                    )
                                  : const SizedBox(),
                            )
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 1600),
                          curve: Curves.decelerate,
                        ),
                    Align(
                      alignment: const Alignment(0, -0.2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Round Finished!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                            ),
                          ).animate().slideY(
                                duration: const Duration(milliseconds: 500),
                                begin: -10.0,
                                end: 0.0,
                                delay: const Duration(milliseconds: 1600),
                                curve: Curves.decelerate,
                              ),
                          const SizedBox(height: 48),
                          _TrophiesRow(
                            screenSize: screenSize,
                            matchResult: state.matchResult!,
                          ),
                          const SizedBox(height: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 640,
                                child: Divider(
                                  color: Colors.white38,
                                  thickness: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppOutlinedButton(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: switch (screenSize) {
                                    ScreenSize.extraSmall ||
                                    ScreenSize.small =>
                                      8.0,
                                    ScreenSize.medium => 10.0,
                                    ScreenSize.large ||
                                    ScreenSize.extraLarge =>
                                      14.0,
                                  },
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/ic_menu.svg',
                                      height: 24,
                                      width: 24,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'All Scores',
                                      style: TextStyle(
                                        color: Color(0xFF83BEFF),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  final rawScores = state.matchResult!.scores
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final record = entry.value;
                                    final index = entry.key;
                                    final rank = index + 1;
                                    return (
                                      name: record.user.showingName,
                                      isMe: record.user.id == myId,
                                      dashType:
                                          DashType.fromUserId(record.user.id),
                                      score: record.score,
                                      rank: rank,
                                    );
                                  }).toList();
                                  RawScoresDialog.show(
                                    context,
                                    scores: rawScores,
                                    allowEditDisplayName: false,
                                  );
                                },
                              ),
                            ],
                          ).animate().fadeIn(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 1500),
                              ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BigButton(
                            bgColor: AppColors.blueButtonBgColor,
                            strokeColor: Colors.white,
                            onPressed: context
                                .read<MatchResultCubit>()
                                .playAgainClicked,
                            child: const Text(
                              'PLAY AGAIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppOutlinedButton(
                            strokeColor: Colors.transparent,
                            onPressed: _shareScore,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ic_share.svg',
                                  height: 22,
                                  width: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Share score',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: bottomPadding),
                        ],
                      ),
                    ).animate().slideY(
                          duration: const Duration(milliseconds: 500),
                          begin: 1.0,
                          end: 0.0,
                          delay: const Duration(milliseconds: 1600),
                          curve: Curves.decelerate,
                        ),
                  ],
                ),
              ],
              if (state.error.isNotEmpty)
                Center(
                  child: ErrorRetryBox(
                    error: state.error,
                    retry: context.read<MatchResultCubit>().retry,
                  ),
                ),
              if (state.isLoading) const LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _shareScore() {
    late int myScore;
    late int myRank;
    final state = context.read<MatchResultCubit>().state;
    final myId = context.read<AccountCubit>().state.currentAccount?.user.id;
    for (var i = 0; i < state.matchResult!.scores.length; i++) {
      if (state.matchResult!.scores[i].user.id == myId) {
        myScore = state.matchResult!.scores[i].score;
        myRank = i + 1;
        break;
      }
    }

    final rankText = switch (myRank) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${myRank}th',
    };
    const subject = '🏆 Flappy Dash Round Finished! 🏆';
    final message = '''
🎉 I finished $rankText place, passing $myScore pipes!

How far can you go? Try Flappy Dash now! 🚀

🔗 play.flappydash.com
''';

    ShareDialog.share(
      context,
      dialogTitle: subject,
      body: message,
      platforms: SharePlatform.defaults,
    );
  }
}



