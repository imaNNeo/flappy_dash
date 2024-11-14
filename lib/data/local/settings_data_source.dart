import 'package:package_info_plus/package_info_plus.dart';

class SettingsDataSource {
  Future<(String, int)> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    return (version, int.parse(buildNumber));
  }
}
