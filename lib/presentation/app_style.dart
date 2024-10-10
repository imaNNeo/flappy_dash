import 'dart:ui';

import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const backgroundColor = Color(0xFF0F8B8D);
  static const backgroundColor60 = Color(0x800F8B8D);

  static const boxBgColor = Color(0x66000000);
  static const dialogBgColor = Color(0xFF16425B);
  static const mainColor = Color(0xFF00FBFF);
  static const blueColor = Color(0xFF26CBFE);
  static const darkBlueColor = Color(0xFF2487FC);
  static const whiteTextColor = Color(0xFFF1F1F1);
  static const whiteTextColor2 = Color(0xFFDAD2D8);

  static const leaderboardGoldenColor = Color(0xFFFFD700);
  static const leaderboardGoldenColorText = Color(0xFF1C1B1F);
  static const leaderboardSilverColor = Color(0xFFC0C0C0);
  static const leaderboardSilverColorText = Color(0xFF1C1B1F);
  static const leaderboardBronzeColor = Color(0xFFCD7F32);
  static const leaderboardBronzeColorText = Color(0xFF1C1B1F);

  static const blueButtonBgColor = Color(0xFF2288FA);
  static const blueButtonBgColor50 = Color(0x802288FA);
  static const blueButtonStrokeColor = darkBlueColor;

  static const greenButtonBgColor = backgroundColor60;
  static const greenButtonStrokeColor = Color(0xFF052727);
  static const playerBoxStrokeColor = Color(0x8016425B);

  static const multiplayerScoreboardBgColor = Color(0x99000000);

  static const multiColorGradient = [
    Color(0xFFFF25B2),
    Color(0xFFFF5D27),
    Color(0xFFAE0089),
    Color(0xFF0073FF),
  ];

  static Color getDashColor(DashType type) => switch (type) {
        DashType.flutterDash => const Color(0xFF2AC6FD),
        DashType.limeDash => const Color(0xFFD0FF6F),
        DashType.peachyDash => const Color(0xFFFDBDB3),
        DashType.roseDash => const Color(0xFFFDABE3),
        DashType.sandDash => const Color(0xFFFDCA7B),
        DashType.scarletDash => const Color(0xFFFF635A),
        DashType.skyDash => const Color(0xFFA3EAFF),
        DashType.mintyDash => const Color(0xFF5EF9A5),
        DashType.sunnyDash => const Color(0xFFFFE247),
        DashType.violetDash => const Color(0xFFBEA2FD),
      };
}

class PresentationConstants {
  static const defaultPadding = 16.0;
  static const defaultBorderRadius = 16.0;
  static const defaultBorderRadiusSmall = 8.0;
}