import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MultiplayerScoreBoard extends StatefulWidget {
  const MultiplayerScoreBoard({
    super.key,
    required this.scores,
    this.maxShowingRows = 5,
  });

  final int maxShowingRows;
  final List<MultiplayerScore> scores;

  @override
  State<MultiplayerScoreBoard> createState() => _MultiplayerScoreBoardState();
}

class _MultiplayerScoreBoardState extends State<MultiplayerScoreBoard> {
  List<_ScoreRowItem> showingItems = [];

  List<_ScoreRowItem> _getScoreRowItems(List<MultiplayerScore> scores) {
    List<_ScoreRowItem> result = [];

    final myIndex = scores.indexWhere((element) => element.isMe);
    final me = scores[myIndex];
    final beforeMe = scores.sublist(0, myIndex);
    final afterMe = scores.sublist(myIndex + 1);

    if (beforeMe.length + 1 <= widget.maxShowingRows) {
      result.addAll(beforeMe.map((score) => _ScoreRowPlayerItem(score: score)));
    } else {
      result.addAll(beforeMe
          .take(widget.maxShowingRows - 1)
          .map((score) => _ScoreRowPlayerItem(score: score)));
      result.add(_ScoreRowDotsItem());
    }
    result.add(_ScoreRowPlayerItem(score: me));

    int addingAfterCount = 0;
    if (afterMe.isNotEmpty) {
      if ((beforeMe.length + 1) < widget.maxShowingRows) {
        final remainingSlotCount =
            widget.maxShowingRows - (beforeMe.length + 1);
        addingAfterCount = min(remainingSlotCount, afterMe.length);

        for (int i = 0; i < addingAfterCount; i++) {
          result.add(_ScoreRowPlayerItem(score: afterMe[i]));
        }
      }
      if (addingAfterCount < afterMe.length) {
        result.add(_ScoreRowDotsItem());
      }
    }

    return result;
  }

  @override
  void initState() {
    showingItems = _getScoreRowItems(widget.scores);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultiplayerScoreBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.scores, widget.scores)) {
      showingItems = _getScoreRowItems(widget.scores);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final width = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 148.0,
      ScreenSize.medium => 220.0,
      ScreenSize.large || ScreenSize.extraLarge => 280.0,
    };
    final margin = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 6.0,
      ScreenSize.medium => 24.0,
      ScreenSize.large || ScreenSize.extraLarge => 38.0,
    };
    final padding = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 8.0,
      ScreenSize.medium => 18.0,
      ScreenSize.large || ScreenSize.extraLarge => 24.0,
    };

    return SafeArea(
      child: Container(
        width: width,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: AppColors.multiplayerScoreboardBgColor,
          borderRadius: BorderRadius.circular(
            PresentationConstants.defaultBorderRadiusSmall,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.scores.length} Players',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: switch (screenSize) {
                    ScreenSize.extraSmall || ScreenSize.small => 16.0,
                    ScreenSize.medium => 18.0,
                    ScreenSize.large || ScreenSize.extraLarge => 20.0,
                  },
                ),
              ),
              SizedBox(
                  height: switch (screenSize) {
                ScreenSize.extraSmall || ScreenSize.small => 4.0,
                ScreenSize.medium => 6.0,
                ScreenSize.large || ScreenSize.extraLarge => 8.0,
              }),
              ...showingItems.map(
                (item) => item is _ScoreRowPlayerItem
                    ? _MultiplayerScoreRowWidget(
                        score: item.score,
                        screenSize: screenSize,
                      )
                    : _MultiplayerDotsRowWidget(
                        screenSize: screenSize,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiplayerScore with EquatableMixin {
  final String playerId;
  final String displayName;
  final DashType dashType;
  final int score;
  final int rank;
  final bool isMe;

  MultiplayerScore({
    required this.playerId,
    required this.displayName,
    required this.dashType,
    required this.score,
    required this.rank,
    required this.isMe,
  });

  @override
  List<Object?> get props => [
        playerId,
        displayName,
        dashType,
        score,
        rank,
        isMe,
      ];
}

sealed class _ScoreRowItem with EquatableMixin {}

class _ScoreRowPlayerItem extends _ScoreRowItem {
  final MultiplayerScore score;

  _ScoreRowPlayerItem({required this.score});

  @override
  List<Object?> get props => [score];
}

class _ScoreRowDotsItem extends _ScoreRowItem {
  @override
  List<Object?> get props => [];
}

class _MultiplayerDotsRowWidget extends StatelessWidget {
  const _MultiplayerDotsRowWidget({
    required this.screenSize,
  });

  final int dotsCount = 3;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    final rowHeight = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 18.0,
      ScreenSize.medium => 24.0,
      ScreenSize.large || ScreenSize.extraLarge => 30.0,
    };
    final dotSize = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 4.0,
      ScreenSize.medium => 6.0,
      ScreenSize.large || ScreenSize.extraLarge => 8.0,
    };
    final space = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 1.0,
      ScreenSize.medium => 1.5,
      ScreenSize.large || ScreenSize.extraLarge => 2.0,
    };
    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          dotsCount,
          (i) => Container(
            width: dotSize,
            height: dotSize,
            margin: EdgeInsets.symmetric(horizontal: space),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ).toList(),
      ),
    );
  }
}

class _MultiplayerScoreRowWidget extends StatelessWidget {
  const _MultiplayerScoreRowWidget({
    required this.score,
    required this.screenSize,
  });

  final MultiplayerScore score;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    final dashColor = AppColors.getDashColor(score.dashType);

    final height = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 24.0,
      ScreenSize.medium => 34.0,
      ScreenSize.large || ScreenSize.extraLarge => 48.0,
    };
    final rankTextSpace = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 20.0,
      ScreenSize.medium => 32.0,
      ScreenSize.large || ScreenSize.extraLarge => 42.0,
    };
    final scoreTextSpace = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 20.0,
      ScreenSize.medium => 32.0,
      ScreenSize.large || ScreenSize.extraLarge => 42.0,
    };
    final dashSize = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 18.0,
      ScreenSize.medium => 24.0,
      ScreenSize.large || ScreenSize.extraLarge => 32.0,
    };
    final rightPadding = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 12.0,
      ScreenSize.medium => 16.0,
      ScreenSize.large || ScreenSize.extraLarge => 24.0,
    };
    final rankTextSize = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 14.0,
      ScreenSize.medium => 16.0,
      ScreenSize.large || ScreenSize.extraLarge => 18.0,
    };
    final normalTextSize = switch (screenSize) {
      ScreenSize.extraSmall || ScreenSize.small => 12.0,
      ScreenSize.medium => 14.0,
      ScreenSize.large || ScreenSize.extraLarge => 16.0,
    };
    final showingName = score.displayName.isNotNullOrBlank
        ? score.displayName
        : score.dashType.name;
    return DashedContainer(
      drawLeft: false,
      drawRight: false,
      drawTop: score.isMe,
      drawBottom: score.isMe,
      dashWidth: 8,
      dashGap: 8,
      strokeWidth: !score.isMe ? 0 : 1,
      borderColor: dashColor.withOpacity(0.7),
      backgroundColor:
          score.isMe ? Colors.black.withOpacity(0.13) : Colors.transparent,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            SizedBox(
              width: rankTextSpace,
              child: Text(
                score.rank.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: rankTextSize,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 12),
            SvgPicture.asset(
              score.dashType.assetName,
              width: dashSize,
              height: dashSize,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                showingName,
                style: TextStyle(
                  color: dashColor,
                  fontSize: normalTextSize,
                ),
              ),
            ),
            SizedBox(
              width: scoreTextSpace,
              child: Text(
                score.score.toString(),
                style: TextStyle(
                  color: dashColor,
                  fontSize: normalTextSize,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: rightPadding),
          ],
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final bool drawTop;
  final bool drawRight;
  final bool drawBottom;
  final bool drawLeft;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.drawTop = true,
    this.drawRight = true,
    this.drawBottom = true,
    this.drawLeft = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();

    // Draw individual sides if specified
    if (drawTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
    }
    if (drawRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }
    if (drawBottom) {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    if (drawLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
    }

    // Create the dashed path
    var dashPath = _createDashedPath(path, dashWidth, dashGap);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path path, double dashWidth, double dashGap) {
    final dashedPath = Path();
    double distance = 0.0;

    for (var metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final segmentLength = dashWidth + dashGap;
        final extractLength = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, extractLength),
          Offset.zero,
        );
        distance += segmentLength;
      }
      distance = 0.0; // Reset distance for the next side of the path.
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color backgroundColor;
  final double borderRadius;
  final bool drawTop;
  final bool drawRight;
  final bool drawBottom;
  final bool drawLeft;

  const DashedContainer({
    super.key,
    required this.child,
    this.borderColor = Colors.black,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 0.0,
    this.drawTop = true,
    this.drawRight = true,
    this.drawBottom = true,
    this.drawLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: borderColor,
          strokeWidth: strokeWidth,
          dashWidth: dashWidth,
          dashGap: dashGap,
          drawTop: drawTop,
          drawRight: drawRight,
          drawBottom: drawBottom,
          drawLeft: drawLeft,
        ),
        child: Padding(
          padding: EdgeInsets.all(strokeWidth),
          child: child,
        ),
      ),
    );
  }
}
