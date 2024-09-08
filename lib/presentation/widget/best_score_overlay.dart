import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'box_overlay.dart';

class BestScoreOverlay extends StatelessWidget {
  const BestScoreOverlay({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        onTap: onTap,
        child: BoxOverlay(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_trophy.svg',
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.leaderboardGoldenColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Align(
                      alignment: Alignment(0.0, -0.8),
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: AppColors.leaderboardGoldenColorText,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your best',
                    style: TextStyle(
                      color: AppColors.whiteTextColor,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    '122',
                    style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
