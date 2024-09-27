import 'package:flappy_dash/data/remote/nakama_data_source.dart';

class MultiplayerRepository {
  final NakamaDataSource _nakamaDataSource;

  MultiplayerRepository(
    this._nakamaDataSource,
  );

  Future<String> getWaitingMatchId() =>
      _nakamaDataSource.getWaitingMatchId();
}
