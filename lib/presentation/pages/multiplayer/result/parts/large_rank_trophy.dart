part of '../match_result_page.dart';

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
