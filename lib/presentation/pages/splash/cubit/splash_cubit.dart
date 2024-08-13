import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/game_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._gameRepository,
  ) : super(const SplashState());

  static const _splashDuration = Duration(seconds: 2);
  final GameRepository _gameRepository;

  void onPageOpen() async {
    try {
      final startTime = DateTime.now();
      await _gameRepository.initSession();

      final endTime = DateTime.now();
      final difference = endTime.difference(startTime);
      if (difference < _splashDuration) {
            await Future.delayed(_splashDuration - difference);
          }

      _openHomePage();
    } catch (e, stack) {
      print('error: $e, $stack');
    }
  }

  void _openHomePage() async {
    emit(state.copyWith(openHomePage: true));
    emit(state.copyWith(openHomePage: false));
  }
}
