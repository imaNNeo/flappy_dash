enum DashType {
  flutterDash,
  limeDash,
  peachyDash,
  roseDash,
  sandDash,
  scarletDash,
  skyDash,
  mintyDash,
  sunnyDash,
  violetDash;

  static DashType fromUserId(String userId) {
    int sum = 0;
    for (int i = 0; i < userId.length; i++) {
      sum += userId.codeUnitAt(i);
    }
    final index = sum % DashType.values.length;
    return DashType.values[index];
  }

  String get name => switch (this) {
    DashType.flutterDash => 'Flutter Dash',
    DashType.limeDash => 'Lime Dash',
    DashType.peachyDash => 'Peachy Dash',
    DashType.roseDash => 'Rose Dash',
    DashType.sandDash => 'Sand Dash',
    DashType.scarletDash => 'Scarlet Dash',
    DashType.skyDash => 'Sky Dash',
    DashType.mintyDash => 'Minty Dash',
    DashType.sunnyDash => 'Sunny Dash',
    DashType.violetDash => 'Violet Dash',
  };
}
