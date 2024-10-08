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

  String get _fileName => switch (this) {
        DashType.flutterDash => 'flutter_dash.svg',
        DashType.limeDash => 'lime_dash.svg',
        DashType.peachyDash => 'peachy_dash.svg',
        DashType.roseDash => 'rose_dash.svg',
        DashType.sandDash => 'sand_dash.svg',
        DashType.scarletDash => 'scarlet_dash.svg',
        DashType.skyDash => 'sky_dash.svg',
        DashType.mintyDash => 'minty_dash.svg',
        DashType.sunnyDash => 'sunny_dash.svg',
        DashType.violetDash => 'violet_dash.svg',
      };

  String get flameAssetName => 'images/dashes/$_fileName';

  String get assetName => 'assets/$flameAssetName';
}
