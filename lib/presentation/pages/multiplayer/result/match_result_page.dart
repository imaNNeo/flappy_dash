import 'dart:math';

import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
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

import 'cubit/match_result_cubit.dart';

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

        if (state.matchResult != null) {
          final myId =
              context.read<AccountCubit>().state.currentAccount?.user.id;
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
                                onPressed: () {},
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
                            onPressed: () {},
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
}

class _TrophiesRow extends StatelessWidget {
  const _TrophiesRow({
    required this.matchResult,
    required this.screenSize,
  });

  final MatchResultEntity matchResult;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;
    final bigTrophyWidth = switch (screenSize) {
      ScreenSize.extraSmall => 80.0,
      ScreenSize.small => 120.0,
      ScreenSize.medium => 160.0,
      ScreenSize.large => 200.0,
      ScreenSize.extraLarge => 260.0,
    };
    final scores = matchResult.scores;

    ({String name, DashType dashType, int score})? firstData;
    ({String name, DashType dashType, int score})? secondData;
    ({String name, DashType dashType, int score})? thirdData;

    if (scores.isNotEmpty) {
      firstData = (
        name: scores[0].user.showingName,
        dashType: DashType.fromUserId(scores[0].user.id),
        score: scores[0].score,
      );
    }

    if (scores.length > 1) {
      secondData = (
        name: scores[1].user.showingName,
        dashType: DashType.fromUserId(scores[1].user.id),
        score: scores[1].score,
      );
    }

    if (scores.length > 2) {
      thirdData = (
        name: scores[2].user.showingName,
        dashType: DashType.fromUserId(scores[2].user.id),
        score: scores[2].score,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _LargeRankTrophy(
          rank: 2,
          data: secondData,
          bigTrophyWidth: bigTrophyWidth,
        ),
        const SizedBox(width: 32),
        _LargeRankTrophy(
          rank: 1,
          data: firstData,
          bigTrophyWidth: bigTrophyWidth,
        ),
        const SizedBox(width: 32),
        _LargeRankTrophy(
          rank: 3,
          data: thirdData,
          bigTrophyWidth: bigTrophyWidth,
        ),
      ],
    );
  }
}

class _LargeRankTrophy extends StatelessWidget {
  const _LargeRankTrophy({
    required this.rank,
    required this.data,
    this.bigTrophyWidth = 200.0,
  });

  static const _trophyImageRatio = 1.3221484375;

  final int rank;
  final ({String name, DashType dashType, int score})? data;
  final double bigTrophyWidth;

  @override
  Widget build(BuildContext context) {
    final firstTrophyWidth = bigTrophyWidth;
    const otherTrophiesRatio = 0.7;
    final trophyWidth =
        rank == 1 ? firstTrophyWidth : firstTrophyWidth * otherTrophiesRatio;
    final trophyHeight = trophyWidth / _trophyImageRatio;

    const animationDuration = 500;
    const animationDelay = 100;
    return SizedBox(
      width: firstTrophyWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: trophyWidth,
            height: trophyHeight,
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/trophies/trophy$rank.svg',
                  width: trophyWidth,
                  height: trophyHeight,
                ),
                Align(
                  alignment: const Alignment(0, 1.0),
                  child: Text(
                    data?.score.toString() ?? '',
                    style: TextStyle(
                      color: const Color(0xFF631C04),
                      fontSize: trophyWidth * 0.12,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: trophyWidth * 0.02),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              data == null
                  ? SizedBox(
                      width: trophyWidth * 0.17,
                      height: trophyWidth * 0.17,
                    )
                  : DashImage(
                      size: trophyWidth * 0.17,
                      type: data!.dashType,
                    ),
              SizedBox(width: trophyWidth * 0.02),
              OutlineText(
                Text(
                  data?.name ?? '',
                  style: TextStyle(
                    color: AppColors.getDashColor(
                      data?.dashType ?? DashType.flutterDash,
                    ),
                    fontSize: min(trophyWidth * 0.1, 24.0),
                  ),
                ),
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    ).animate().scaleXY(
          duration: const Duration(milliseconds: animationDuration),
          begin: 0.0,
          end: 1.0,
          delay: Duration(
            milliseconds: animationDelay + (rank - 1) * animationDuration,
          ),
          curve: Curves.easeOutBack,
        );
  }
}

class _CurrentPlayerScoreBox extends StatelessWidget {
  const _CurrentPlayerScoreBox({
    required this.data,
  });

  final ({int rank, String name, DashType dashType, int score}) data;

  @override
  Widget build(BuildContext context) {
    final dashType = data.dashType;
    return SizedBox(
      child: DashedContainer(
        borderColor: AppColors.getDashColor(dashType),
        borderRadius: 4.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              data.rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            DashImage(
              size: 28,
              type: dashType,
            ),
            const SizedBox(width: 4),
            OutlineText(
              Text(
                data.name,
                style: TextStyle(
                  color: AppColors.getDashColor(dashType),
                  fontSize: 16,
                ),
              ),
              strokeWidth: 2,
              strokeColor: Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              data.score.toString(),
              style: TextStyle(
                color: AppColors.getDashColor(dashType),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
