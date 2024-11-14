import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/data/local/settings_data_source.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:get_it/get_it.dart';

import 'data/local/device_data_source.dart';
import 'data/remote/nakama_data_source.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/settings_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<AudioHelper>(() => AudioHelper());

  // DataSources
  getIt.registerLazySingleton<NakamaDataSource>(
    () => NakamaDataSource(),
  );
  getIt.registerLazySingleton<DeviceDataSource>(
    () => DeviceDataSource(),
  );
  getIt.registerLazySingleton<SettingsDataSource>(
    () => SettingsDataSource(),
  );

  // Repositories
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepository(
      getIt.get<DeviceDataSource>(),
      getIt.get<NakamaDataSource>(),
    ),
  );
  getIt.registerLazySingleton<MultiplayerRepository>(
    () => MultiplayerRepository(
      getIt.get<NakamaDataSource>(),
    ),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(
      getIt.get<SettingsDataSource>(),
      getIt.get<NakamaDataSource>(),
    ),
  );
}
