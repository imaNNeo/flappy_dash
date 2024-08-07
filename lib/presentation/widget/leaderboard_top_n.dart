import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';

class LeaderboardTopN extends StatelessWidget {
  const LeaderboardTopN({
    super.key,
    required this.leaderboard,
    this.nCount = 5,
  });

  final LeaderboardRecordList leaderboard;
  final int nCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: leaderboard.records
              .take(nCount)
              .map(
                (record) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              width: 180,
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                color: Colors.black12,
              ),
              child: Row(
                children: [
                  Text(
                    "${record.rank}.",
                    style: const TextStyle(
                      color: Color(0xFFE76802),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    record.username ?? record.ownerId ?? 'Anonymous',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  Expanded(child: Container()),
                  Text(
                    record.score.toString(),
                    style: const TextStyle(
                      color: Color(0xFF2387FC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}