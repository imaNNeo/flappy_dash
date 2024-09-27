import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._multiplayerRepository,
  ) : super(HomeState());

  final MultiplayerRepository _multiplayerRepository;

  void onMultiPlayerButtonPressed() async {
    if (state.multiPlayerMatchIdLoading) {
      return;
    }
    emit(state.copyWith(multiPlayerMatchIdLoading: true));
    try {
      final matchId = await _multiplayerRepository.getWaitingMatchId();
      emit(state.copyWith(
        multiPlayerMatchIdLoading: false,
        openMultiplayerLobby: matchId,
      ));
      emit(state.copyWith(
        openMultiplayerLobby: '',
        multiPlayerMatchIdLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        multiPlayerMatchIdLoading: false,
        multiPlayerMatchIdError: 'Failed to load the match',
      ));
      emit(state.copyWith(
        multiPlayerMatchIdError: '',
      ));
    }
  }
}
