import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flutter/material.dart';

/// Makes a group of widgets always fit the space it gets.
///
/// On small and short screens the group scales down instead of overflowing.
/// On large screens (desktop, ultrawide) it scales up to fill
/// [widthFraction] x [heightFraction] of the space, so the menus don't look
/// lost in the middle of a big monitor.
class FitContent extends StatelessWidget {
  const FitContent({
    super.key,
    required this.child,
    this.widthFraction = 0.55,
    this.heightFraction = 0.7,
  });

  final Widget child;
  final double widthFraction;
  final double heightFraction;

  @override
  Widget build(BuildContext context) {
    final grow =
        ScreenSize.fromContext(context).index >= ScreenSize.large.index;
    if (!grow) {
      return Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: constraints.maxWidth * widthFraction,
            height: constraints.maxHeight * heightFraction,
            child: FittedBox(fit: BoxFit.contain, child: child),
          ),
        );
      },
    );
  }
}
