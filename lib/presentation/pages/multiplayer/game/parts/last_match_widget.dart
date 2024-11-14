import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/widget/dash_image.dart';
import 'package:flutter/material.dart';

class LastMatchWidget extends StatelessWidget {
  const LastMatchWidget({
    super.key,
    this.height = 72.0,
  });

  final double height;
  static const ratio = 126 / 61;

  @override
  Widget build(BuildContext context) {
    final width = height * ratio;
    const radius = Radius.circular(18);
    const dashType = DashType.violetDash;
    const playerName = 'LongestName';
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
                fontSize: width * 0.09,
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
                    fontSize: width * 0.11,
                  ),
                ),
              ],
            ),
            Text(
              '23 minutes ago',
              style: TextStyle(
                color: Colors.white60,
                fontSize: width * 0.07,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
