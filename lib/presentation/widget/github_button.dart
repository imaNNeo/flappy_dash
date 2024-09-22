import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GithubButton extends StatelessWidget {
  const GithubButton({
    super.key,
    required this.screenSize,
  });

  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    final iconSize = switch (screenSize) {
      ScreenSize.extraSmall => 28.0,
      ScreenSize.small => 32.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 48.0,
    };

    final padding = switch (screenSize) {
      ScreenSize.extraSmall => 6.0,
      ScreenSize.small => 12.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 24.0,
    };

    final fontSize = switch (screenSize) {
      ScreenSize.extraSmall => 12.0,
      ScreenSize.small => 14.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 16.0,
    };
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            PresentationConstants.defaultBorderRadius,
          ),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_github.svg',
                  height: iconSize,
                  width: iconSize,
                ),
                Text(
                  'Source Code',
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
