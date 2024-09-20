import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'box_overlay.dart';

class ProfileOverlay extends StatelessWidget {
  const ProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxOverlay(
      onTap: () => AppDialogs.nicknameDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/ic_profile.svg',
            height: 32,
          ),
          const SizedBox(width: 12),
          BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              final displayName = state.currentUserAccount?.user.displayName;

              return Text(
                displayName.isNotNullOrBlank ? displayName! : 'My Profile',
                style: const TextStyle(
                  color: AppColors.mainColor,
                  fontSize: 24,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
