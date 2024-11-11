import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
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
                        IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
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
                    itemBuilder: (context, index) {
                      return DebugTextLine(
                        words: state.debugMessages[index].toDebugMessage(),
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
  }
}


