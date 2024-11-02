import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/dialogs/nickname_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef RawScoreRecord = ({
  String name,
  bool isMe,
  DashType dashType,
  int score,
  int rank,
});

class RawScoresDialog extends StatelessWidget {
  static Future<T?> show<T>(
    BuildContext context, {
    required List<RawScoreRecord> scores,
    bool allowEditDisplayName = true,
        String title = 'Scores',
  }) =>
      showDialog<T?>(
        context: context,
        builder: (context) {
          return RawScoresDialog(
            scores: scores,
            allowEditDisplayName: allowEditDisplayName,
            title: title,
          );
        },
      );

  const RawScoresDialog({
    super.key,
    required this.scores,
    this.title = 'Leaderboard',
    this.width = 400,
    this.height = 600,
    this.allowEditDisplayName = true,
  });

  final String title;
  final List<RawScoreRecord> scores;

  final double width;
  final double height;

  final bool allowEditDisplayName;

  @override
  Widget build(BuildContext context) {
    const closeIconSize = 38.0;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.dialogBgColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          border: Border.all(
            color: Colors.black,
            width: 6,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 0.1,
              blurRadius: 0,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: closeIconSize),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.whiteTextColor,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: SvgPicture.asset(
                    'assets/icons/ic_close.svg',
                    width: closeIconSize,
                    height: closeIconSize,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height,
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 18, bottom: 12),
                itemBuilder: (context, index) {
                  final record = scores[index];

                  return LeaderboardRow(
                    rank: record.rank,
                    name: record.name,
                    score: record.score,
                    isMine: record.isMe,
                    allowEditDisplayName: allowEditDisplayName,
                    onMyProfileTap: allowEditDisplayName
                        ? () => NicknameDialog.show(context)
                        : null,
                  );
                },
                separatorBuilder: (context, index) => Container(
                  height: 1,
                  color: Colors.white10,
                ),
                itemCount: scores.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.isMine,
    required this.onMyProfileTap,
    required this.allowEditDisplayName,
  });

  final int rank;
  final String name;
  final int score;
  final bool isMine;
  final VoidCallback? onMyProfileTap;
  final bool allowEditDisplayName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMine ? onMyProfileTap : null,
        child: Container(
          color: isMine ? Colors.white10 : Colors.transparent,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              rank <= 3
                  ? ScoreTrophy(
                      size: 38,
                      rank: rank,
                    )
                  : NormalScore(
                      size: 38,
                      rank: rank,
                    ),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  color: isMine ? Colors.white : AppColors.whiteTextColor2,
                  fontSize: 28,
                ),
              ),
              if (isMine && allowEditDisplayName) ...[
                const SizedBox(width: 4),
                const Align(
                  alignment: Alignment(0, 0.3),
                  child: Text(
                    '(edit)',
                    style: TextStyle(
                      color: AppColors.blueColor,
                    ),
                  ),
                ),
              ],
              Expanded(child: Container()),
              Text(
                score.toString(),
                style: const TextStyle(
                  color: AppColors.blueColor,
                  fontSize: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreTrophy extends StatelessWidget {
  const ScoreTrophy({
    super.key,
    required this.size,
    required this.rank,
  });

  final double size;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/icons/ic_trophy.svg',
            height: size,
            colorFilter: ColorFilter.mode(
              switch (rank) {
                null || 1 => AppColors.leaderboardGoldenColor,
                2 => AppColors.leaderboardSilverColor,
                3 => AppColors.leaderboardBronzeColor,
                _ => throw StateError('Invalid rank: $rank'),
              },
              BlendMode.srcIn,
            ),
          ),
          Align(
            alignment: const Alignment(0.0, -0.8),
            child: Text(
              rank == null ? '?' : rank.toString(),
              style: TextStyle(
                color: switch (rank) {
                  null || 1 => AppColors.leaderboardGoldenColorText,
                  2 => AppColors.leaderboardSilverColorText,
                  3 => AppColors.leaderboardBronzeColorText,
                  _ => throw StateError('Invalid rank: $rank'),
                },
                fontSize: size * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NormalScore extends StatelessWidget {
  const NormalScore({
    super.key,
    required this.size,
    required this.rank,
  });

  final double size;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mainColor,
        ),
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: AppColors.mainColor,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
