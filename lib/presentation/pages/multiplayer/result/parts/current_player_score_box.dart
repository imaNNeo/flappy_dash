part of '../match_result_page.dart';

class _CurrentPlayerScoreBox extends StatelessWidget {
  const _CurrentPlayerScoreBox({
    required this.data,
  });

  final ({int rank, String name, DashType dashType, int score}) data;

  @override
  Widget build(BuildContext context) {
    final dashType = data.dashType;
    return DashedContainer(
      borderColor: AppColors.getDashColor(dashType),
      borderRadius: 4.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            ScoreTrophy(
              size: 24,
              rank: data.rank,
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
