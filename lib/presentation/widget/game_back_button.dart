import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameBackButton extends StatelessWidget {
  const GameBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final backIconSize = switch (screenSize) {
      ScreenSize.extraSmall => 24.0,
      ScreenSize.small => 28.0,
      ScreenSize.medium => 38.0,
      ScreenSize.large || ScreenSize.extraLarge => 42.0,
    };
    return Padding(
      padding: EdgeInsets.only(left: backIconSize * 0.4),
      child: IconButton(
        padding: EdgeInsets.all(backIconSize * 0.5),
        icon: SvgPicture.asset(
          'assets/icons/ic_back.svg',
          width: backIconSize,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
