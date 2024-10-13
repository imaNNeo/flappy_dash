import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/widget/error_retry_box.dart';
import 'package:flappy_dash/presentation/widget/loading_overlay.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/match_result_cubit.dart';

class MatchResultPage extends StatelessWidget {
  const MatchResultPage({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchResultCubit(
        gameRepository: getIt.get<MultiplayerRepository>(),
        matchId: matchId,
      ),
      child: _MatchResultPageContent(),
    );
  }
}

class _MatchResultPageContent extends StatefulWidget {
  @override
  State<_MatchResultPageContent> createState() =>
      _MatchResultPageContentState();
}

class _MatchResultPageContentState extends State<_MatchResultPageContent> {
  @override
  void initState() {
    context.read<MatchResultCubit>().pageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchResultCubit, MatchResultState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              if (state.matchResult != null)
                Center(
                  child: Text(
                    state.matchResult.toString(),
                  ),
                ),
              if (state.error.isNotEmpty)
                Center(
                  child: ErrorRetryBox(
                    error: state.error,
                    retry: context.read<MatchResultCubit>().retry,
                  ),
                ),
              if (state.isLoading) const LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }
}
