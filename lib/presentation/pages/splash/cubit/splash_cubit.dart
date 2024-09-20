import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._gameRepository,
  ) : super(const SplashState());

  static const _splashDuration = Duration(seconds: 2);
  final GameRepository _gameRepository;

  Future<void> _initialize() async {
    await _gameRepository.initSession();
    await getIt.get<AudioHelper>().initialize();
  }

  void onPageOpen() async {
    try {
      final startTime = DateTime.now();
      await _initialize();
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
