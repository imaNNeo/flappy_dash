import 'package:flappy_dash/data/local/settings_data_source.dart';
import 'package:flappy_dash/data/remote/nakama_data_source.dart';

class SettingsRepository {
  SettingsRepository(
    this._settingsDataSource,
    this._nakamaDataSource,
  );

  final SettingsDataSource _settingsDataSource;
  final NakamaDataSource _nakamaDataSource;

  Future<(String, int)> getAppVersion() => _settingsDataSource.getAppVersion();

  Future<bool> isVersionUpToDate() async {
    final config = await _nakamaDataSource.getServerConfig();
    final (_, versionCode) = await getAppVersion();
    return versionCode >= config.minimumAppVersion;
  }
}
