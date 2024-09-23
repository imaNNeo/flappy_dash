import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashPlayerBox extends StatelessWidget {
  const DashPlayerBox({
    super.key,
    required this.playerName,
  });

  final String playerName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxWidth = constraints.maxWidth;
      final iconSize = boxWidth * 0.25;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PresentationConstants.defaultBorderRadiusSmall,
          ),
          border: Border.all(
            color: AppColors.playerBoxStrokeColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: boxWidth * 0.04),
            SvgPicture.asset(
              'assets/images/dash.svg',
              width: iconSize,
              height: iconSize,
            ),
            SizedBox(width: boxWidth * 0.04),
            Expanded(
              child: Text(
                playerName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: boxWidth * 0.12,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
