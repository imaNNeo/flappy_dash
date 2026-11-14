import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The frame every in-game dialog uses: the dark blue card with the chunky
/// black outline, a title bar and a close button.
///
/// It never grows past the screen: on short or narrow windows it shrinks and
/// its [child] gets the remaining space (so a list inside should scroll).
class GameDialog extends StatelessWidget {
  const GameDialog({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 440,
    this.maxHeight = 720,
    this.showCloseButton = true,
  });

  final String title;
  final Widget child;
  final double maxWidth;
  final double maxHeight;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 480 || size.height < 520;
    const closeIconSize = 32.0;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 40,
        vertical: compact ? 12 : 32,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.dialogBgColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: Colors.black, width: 5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black38,
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: compact ? 52 : 60,
                child: Row(
                  children: [
                    const SizedBox(width: closeIconSize + 16),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.whiteTextColor,
                          fontSize: compact ? 24 : 28,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: closeIconSize + 16,
                      child: showCloseButton
                          ? IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: SvgPicture.asset(
                                'assets/icons/ic_close.svg',
                                width: closeIconSize,
                                height: closeIconSize,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
