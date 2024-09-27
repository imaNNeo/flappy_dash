import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:get_it/get_it.dart';

import 'data/local/device_data_source.dart';
import 'data/remote/nakama_data_source.dart';
import 'domain/repositories/game_repository.dart';

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

}
