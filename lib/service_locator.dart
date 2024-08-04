import 'package:flappy_dash/data/remote/nakama_data_source.dart';
import 'package:flappy_dash/domain/game_repository.dart';
import 'package:flappy_dash/presentation/audio_helper.dart';
import 'package:get_it/get_it.dart';

import 'data/local/device_data_source.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<AudioHelper>(() => AudioHelper());

  // data sources
  getIt.registerLazySingleton<NakamaDataSource>(
    () => NakamaDataSource(),
  );
  getIt.registerLazySingleton<DeviceDataSource>(
    () => DeviceDataSource(),
  );

  // repositories
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepository(
      getIt.get<NakamaDataSource>(),
      getIt.get<DeviceDataSource>(),
    ),
  );
}
