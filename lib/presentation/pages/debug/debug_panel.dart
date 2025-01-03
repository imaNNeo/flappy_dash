import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/ping/ping_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'debug_text_line.dart';

class DebugPanel extends StatefulWidget {
  const DebugPanel({super.key});

  @override
  State<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<DebugPanel> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    const padding = 8.0;
    const headerHeight = 40.0;
    const expandedHeight = 500.0;
    const collapsedHeight = headerHeight + padding * 2;
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        if (!(kDebugMode || accountState.isDebugUser)) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<MultiplayerCubit, MultiplayerState>(
          builder: (context, state) {
            return Material(
              color: Colors.transparent,
              child: Container(
                width: 440,
                height: isExpanded ? collapsedHeight : expandedHeight,
                padding: const EdgeInsets.all(padding),
                color: Colors.black87,
                child: Column(
                  children: [
                    SizedBox(
                      height: headerHeight,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Debug Panel (${state.debugMessages.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                            ),
                            const _PingText(),
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemBuilder: (context, reverseIndex) {
                          final index =
                              state.debugMessages.length - 1 - reverseIndex;
                          return DebugTextLine(
                            words: state.debugMessages[index].toDebugMessage(
                              state.currentUserId,
                            ),
                          );
                        },
                        itemCount: state.debugMessages.length,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PingText extends StatelessWidget {
  const _PingText();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PingCubit, PingState>(
      builder: (context, state) {
        if (state.currentPing == null) {
          return const SizedBox();
        }

        final ping = state.currentPing!;
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${ping.total.toString()} (',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
              TextSpan(
                text: '↑${ping.send.toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
              TextSpan(
                text: ' ↓${ping.recieve.toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const TextSpan(
                text: ')ms',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
