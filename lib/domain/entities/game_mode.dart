import 'package:flappy_dash/domain/entities/game_config_entity.dart';

sealed class GameMode {
  const GameMode();

  abstract final GameConfigEntity gameConfig;
}

class SinglePlayerGameMode extends GameMode {
  const SinglePlayerGameMode({
    this.gameConfig = const SinglePlayerGameConfigEntity(),
  });

  @override
  final SinglePlayerGameConfigEntity gameConfig;
}

class MultiplayerGameMode extends GameMode {
  const MultiplayerGameMode({
    this.gameConfig = const MultiplayerGameConfigEntity(),
  });

  @override
  final MultiplayerGameConfigEntity gameConfig;
}
