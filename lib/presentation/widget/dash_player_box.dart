import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';

import 'dash_image.dart';

class DashPlayerBox extends StatelessWidget {
  const DashPlayerBox({
    super.key,
    required this.playerUserId,
    required this.playerName,
    required this.isMe,
  });

  final String playerUserId;
  final String playerName;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxWidth = constraints.maxWidth;
      final iconSize = boxWidth * 0.25;
      final dashType = DashType.fromUserId(playerUserId);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PresentationConstants.defaultBorderRadiusSmall,
          ),
          border: Border.all(
            color: AppColors.playerBoxStrokeColor,
            width: 2,
          ),
          color: isMe ? AppColors.boxBgColor : null,
        ),
        child: Row(
          children: [
            SizedBox(width: boxWidth * 0.04),
            DashImage(size: iconSize, type: dashType),
            SizedBox(width: boxWidth * 0.04),
            Expanded(
              child: OutlineText(
                Text(
                  playerName.isNotBlank ? playerName : dashType.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.getDashColor(dashType),
                    fontSize: boxWidth * 0.10,
                  ),
                ),
                strokeWidth: 2,
                strokeColor: Colors.black,
              ),
            )
          ],
        ),
      );
    });
  }
}
