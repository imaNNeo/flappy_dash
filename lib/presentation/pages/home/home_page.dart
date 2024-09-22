import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/single_player');
              },
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.go('/lobby:asdfasdf');
              },
              child: const Text('Multi Player'),
            ),
          ],
        ),
      ),
    );
  }
}
