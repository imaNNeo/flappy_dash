import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'match_result_state.dart';

class MatchResultCubit extends Cubit<MatchResultState> {
  MatchResultCubit({
    required this.gameRepository,
    required String matchId,
  }) : super(MatchResultState(
          matchId: matchId,
        ));

  final MultiplayerRepository gameRepository;

  void pageOpen() {
    _fetchMatchResult();
  }

  void _fetchMatchResult() async {
    emit(state.copyWith(
      isLoading: true,
      error: '',
    ));
    try {
      final matchResult = await gameRepository.getMatchResult(state.matchId);
      emit(state.copyWith(
        isLoading: false,
        matchResult: matchResult,
      ));
    } catch (e, stack) {
      debugPrint(stack.toString());
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void playAgainClicked() async {
    emit(state.copyWith(
      playAgainLoading: true,
    ));
    try {
      final matchId = await gameRepository.getWaitingMatchId();
      emit(state.copyWith(
        playAgainLoading: false,
        playAgainMatchId: matchId,
      ));
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(
        playAgainLoading: false,
        playAgainError: e.toString(),
      ));
      emit(state.copyWith(
        playAgainError: '',
      ));
    }
  }

  void retry() {
    _fetchMatchResult();
  }
}
