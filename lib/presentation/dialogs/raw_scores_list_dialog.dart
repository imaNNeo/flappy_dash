import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/dialogs/nickname_dialog.dart';
import 'package:flappy_dash/presentation/widget/game_dialog.dart';
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
  }) => showDialog<T?>(
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
    return GameDialog(
      title: title,
      maxWidth: width,
      maxHeight: height + 60,
      child: scores.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No scores yet',
                style: TextStyle(color: Colors.white60, fontSize: 20),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 4, bottom: 12),
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
              separatorBuilder: (context, index) =>
                  Container(height: 1, color: Colors.white10),
              itemCount: scores.length,
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
    final compact = MediaQuery.sizeOf(context).width < 480;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMine ? onMyProfileTap : null,
        child: Container(
          color: isMine ? Colors.white10 : Colors.transparent,
          height: compact ? 54 : 64,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
          child: Row(
            children: [
              rank <= 3
                  ? ScoreTrophy(size: compact ? 32 : 38, rank: rank)
                  : NormalScore(size: compact ? 32 : 38, rank: rank),
              SizedBox(width: compact ? 10 : 16),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isMine
                              ? Colors.white
                              : AppColors.whiteTextColor2,
                          fontSize: compact ? 22 : 28,
                        ),
                      ),
                    ),
                    if (isMine && allowEditDisplayName) ...[
                      const SizedBox(width: 4),
                      const Align(
                        alignment: Alignment(0, 0.3),
                        child: Text(
                          '(edit)',
                          style: TextStyle(color: AppColors.blueColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                score.toString(),
                style: TextStyle(
                  color: AppColors.blueColor,
                  fontSize: compact ? 28 : 36,
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
  const ScoreTrophy({super.key, required this.size, required this.rank});

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
            colorFilter: ColorFilter.mode(switch (rank) {
              null || 1 => AppColors.leaderboardGoldenColor,
              2 => AppColors.leaderboardSilverColor,
              3 => AppColors.leaderboardBronzeColor,
              _ => throw StateError('Invalid rank: $rank'),
            }, BlendMode.srcIn),
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
  const NormalScore({super.key, required this.size, required this.rank});

  final double size;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.mainColor),
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            color: AppColors.mainColor,
            fontSize: size * 0.63,
            height: 1,
          ),
        ),
      ),
    );
  }
}
