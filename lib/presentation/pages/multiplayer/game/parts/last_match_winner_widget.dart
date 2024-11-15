import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/entities/match_overview_entity.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/domain/utils/date_time_utils.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/widget/dash_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LastMatchWinnerWidget extends StatelessWidget {
  const LastMatchWinnerWidget({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        return _AnimatedLastMatchWidget(
          lastMatch: state.lastMatchOverview,
          height: height,
        );
      },
    );
  }
}

class _AnimatedLastMatchWidget extends StatefulWidget {
  const _AnimatedLastMatchWidget(
      {required this.lastMatch, required this.height})
      : width = height * ratio;

  final double height;
  final double width;
  static const ratio = 120 / 67;

  final MatchOverviewEntity? lastMatch;

  @override
  State<_AnimatedLastMatchWidget> createState() =>
      _AnimatedLastMatchWidgetState();
}

class _AnimatedLastMatchWidgetState extends State<_AnimatedLastMatchWidget> {
  @override
  Widget build(BuildContext context) {
    final topScore = widget.lastMatch?.scores.firstOrNull;
    if (topScore == null) {
      return Container();
    }

    final width = widget.width;
    final height = widget.height;
    const radius = Radius.circular(18);
    final dashType = DashType.fromUserId(topScore.user.id);
    final playerName = topScore.user.displayName ?? '';
    final timeAgo = DateTimeUtils.timeAgo(widget.lastMatch!.finishedAt);

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: radius,
            topRight: radius,
          ),
        ),
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Last winner',
              style: TextStyle(
                color: AppColors.leaderboardGoldenColor,
                fontSize: width * 0.1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DashImage(size: width * 0.2, type: dashType),
                SizedBox(width: width * 0.03),
                Text(
                  playerName.isNotBlank ? playerName : dashType.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.getDashColor(dashType),
                    fontSize: width * 0.13,
                  ),
                ),
              ],
            ),
            Text(
              '$timeAgo ago',
              style: TextStyle(
                color: Colors.white60,
                fontSize: width * 0.1,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutSine,
          delay: const Duration(milliseconds: 300),
        )
        .custom(
      builder: (
        BuildContext context,
        double value,
        Widget child,
      ) {
        return ClipRect(
          clipper: MyCustomClipper(
            showHeightPortion: 1.0,
          ),
          child: child,
        );
      },
    );
  }
}

class MyCustomClipper extends CustomClipper<Rect> {
  final double showHeightPortion;

  MyCustomClipper({super.reclip, required this.showHeightPortion});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height * showHeightPortion);
  }

  @override
  bool shouldReclip(covariant MyCustomClipper oldClipper) =>
      showHeightPortion != oldClipper.showHeightPortion;
}
