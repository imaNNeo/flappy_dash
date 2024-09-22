import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MultiPlayerLobbyPage extends StatelessWidget {
  const MultiPlayerLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('Multiplayer Lobby Page'),
            ElevatedButton(
              onPressed: () {
                context.replace('/multi_player:asdfasdf');
              },
              child: const Text('Multi Player'),
            ),
          ],
        ),
      ),
    );
  }
}
