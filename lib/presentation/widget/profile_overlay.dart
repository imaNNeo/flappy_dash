import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/app_dialogs.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'box_overlay.dart';

class ProfileOverlay extends StatelessWidget {
  const ProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final multiplier = switch(screenSize) {
      ScreenSize.extraSmall => 0.6,
      ScreenSize.small => 0.7,
      ScreenSize.medium => 1.0,
      ScreenSize.large => 1.1,
      ScreenSize.extraLarge => 1.2,
    };
    double relative(double value) => value * multiplier;
    return BoxOverlay(
      padding: EdgeInsets.symmetric(
        horizontal: relative(12.0),
        vertical: relative(6.0),
      ),
      onTap: () => AppDialogs.nicknameDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/dash.svg',
            height: relative(48),
          ),
          SizedBox(width: relative(6)),
          BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              final displayName = state.currentUserAccount?.user.displayName;
              return OutlineText(
                Text(
                  displayName.isNotNullOrBlank ? displayName! : 'My Profile',
                  style: TextStyle(
                    color: AppColors.mainColor,
                    fontSize: relative(24),
                  ),
                ),
                strokeWidth: relative(2),
                strokeColor: Colors.black,
              );
            },
          ),
        ],
      ),
    );
  }
}
