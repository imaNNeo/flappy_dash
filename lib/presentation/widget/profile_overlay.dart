import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
import 'package:flappy_dash/presentation/dialogs/app_dialogs.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'box_overlay.dart';
import 'dash_image.dart';

class ProfileOverlay extends StatelessWidget {
  const ProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final multiplier = switch (screenSize) {
      ScreenSize.extraSmall => 0.6,
      ScreenSize.small => 0.7,
      ScreenSize.medium => 1.0,
      ScreenSize.large => 1.1,
      ScreenSize.extraLarge => 1.2,
    };
    double relative(double value) => value * multiplier;
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final displayName = state.currentAccount?.user.displayName;
        final userId = state.currentAccount?.user.id;
        final dashType =
            userId == null ? DashType.flutterDash : DashType.fromUserId(userId);
        return BoxOverlay(
          padding: EdgeInsets.symmetric(
            horizontal: relative(12.0),
            vertical: relative(6.0),
          ),
          onTap: () => AppDialogs.nicknameDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DashImage(size: relative(48), type: dashType),
              SizedBox(width: relative(6)),
              OutlineText(
                Text(
                  displayName.isNotNullOrBlank ? displayName! : dashType.name,
                  style: TextStyle(
                    color: AppColors.getDashColor(dashType),
                    fontSize: relative(24),
                  ),
                ),
                strokeWidth: relative(2),
                strokeColor: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }
}
