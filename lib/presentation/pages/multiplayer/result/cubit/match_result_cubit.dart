import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/match_result_entity.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
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
    emit(state.copyWith(isLoading: true));
    try {
      final matchResult = await gameRepository.getMatchResult(state.matchId);
      emit(state.copyWith(
        isLoading: false,
        matchResult: matchResult,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void retry() {
    _fetchMatchResult();
  }
}
