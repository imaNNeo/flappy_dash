import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/material.dart';

/// Lets the people the server allows (everybody on a dev server, only the
/// admins in production) add bots to the lobby, so there is always someone to
/// play with. The bots play on the server; everybody sees them.
class BotControlsWidget extends StatefulWidget {
  const BotControlsWidget({super.key, required this.state});

  final MultiplayerState state;

  @override
  State<BotControlsWidget> createState() => _BotControlsWidgetState();
}

enum _BotAction { add, remove }

class _BotControlsWidgetState extends State<BotControlsWidget> {
  final _repository = getIt.get<MultiplayerRepository>();
  bool _canManageBots = false;

  @override
  void initState() {
    super.initState();
    _repository
        .canManageBots()
        .then((allowed) {
          if (mounted && allowed) {
            setState(() => _canManageBots = true);
          }
        })
        .catchError((Object _) {
          // An older server without bots: keep the button hidden.
        });
  }

  @override
  Widget build(BuildContext context) {
    final matchId = widget.state.matchId;
    if (!_canManageBots || matchId.isEmpty) {
      return const SizedBox.shrink();
    }
    final botsCount = widget.state.inLobbyPlayers
        .where((player) => player.isBot)
        .length;
    return PopupMenuButton<_BotAction>(
      tooltip: 'Bots',
      icon: Badge(
        isLabelVisible: botsCount > 0,
        label: Text('$botsCount'),
        child: const Icon(
          Icons.smart_toy_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
      onSelected: (action) => switch (action) {
        _BotAction.add => _repository.addBot(matchId),
        _BotAction.remove => _repository.removeBot(matchId),
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: _BotAction.add, child: Text('Add a bot')),
        PopupMenuItem(
          value: _BotAction.remove,
          enabled: botsCount > 0,
          child: const Text('Remove a bot'),
        ),
      ],
    );
  }
}
