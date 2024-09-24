import 'package:flappy_dash/domain/app_constants.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/presentation_utils.dart';
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
      ScreenSize.extraSmall => 24.0,
      ScreenSize.small => 28.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 38.0,
    };

    final padding = switch (screenSize) {
      ScreenSize.extraSmall => 8.0,
      ScreenSize.small => 12.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 16.0,
    };
    return Tooltip(
      message: 'View on GitHub',
      child: Padding(
        padding: const EdgeInsets.only(
          left: PresentationConstants.defaultPadding / 2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              PresentationConstants.defaultBorderRadiusSmall,
            ),
            onTap: () => PresentationUtils.openUrl(AppConstants.gitHubUrl),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic_github.svg',
                    height: iconSize,
                    width: iconSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
