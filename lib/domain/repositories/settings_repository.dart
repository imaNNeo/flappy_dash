import 'package:flappy_dash/data/local/settings_data_source.dart';

class SettingsRepository {
  SettingsRepository(this._settingsDataSource);

  final SettingsDataSource _settingsDataSource;

  Future<(String, int)> getAppVersion() => _settingsDataSource.getAppVersion();
}
