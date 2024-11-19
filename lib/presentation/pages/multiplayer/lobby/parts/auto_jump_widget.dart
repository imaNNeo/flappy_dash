import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AutoJumpWidget extends StatelessWidget {
  const AutoJumpWidget({
    super.key,
    required this.state,
  });

  final MultiplayerState state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: state.countToTapForAutoJump > 0
          ? context.read<MultiplayerCubit>().tappedOnAutoJumpArea
          : null,
      child: SizedBox(
        height: 60,
        child: state.countToTapForAutoJump <= 0
            ? Tooltip(
                message:
                    'Auto Jump is ${state.isCurrentPlayerAutoJump ? 'ON' : 'OFF'}',
                child: IconButton(
                  onPressed: () {
                    context
                        .read<MultiplayerCubit>()
                        .setAutoJumpEnabled(!state.isCurrentPlayerAutoJump);
                  },
                  icon: Icon(
                    size: 32,
                    Icons.autorenew,
                    color: state.isCurrentPlayerAutoJump
                        ? AppColors.mainColor
                        : Colors.black12,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
