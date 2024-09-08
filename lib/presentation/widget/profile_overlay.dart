import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'box_overlay.dart';

class ProfileOverlay extends StatelessWidget {
  const ProfileOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxOverlay(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/ic_profile.svg',
            height: 32,
          ),
          const SizedBox(width: 12),
          const Text(
            'My Profile',
            style: TextStyle(
              color: AppColors.mainColor,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
