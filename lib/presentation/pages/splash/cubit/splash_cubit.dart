import 'package:equatable/equatable.dart';
import 'package:flappy_dash/audio_helper.dart';
import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/domain/repositories/settings_repository.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._gameRepository,
    this._settingsRepository,
  ) : super(const SplashState());

  static const _splashDuration = Duration(seconds: 2);
  final GameRepository _gameRepository;
  final SettingsRepository _settingsRepository;

  Future<void> _beforeVersionCheckInitialization() async {
    await _gameRepository.initSession();
    await getIt.get<AudioHelper>().initialize();
  }

  void onPageOpen() async {
    try {
      final startTime = DateTime.now();
      await _beforeVersionCheckInitialization();
      if (!(await _settingsRepository.isVersionUpToDate())) {
        emit(state.copyWith(
          versionIsOutdated: true,
        ));
        return;
      }
      final endTime = DateTime.now();
      final difference = endTime.difference(startTime);
      if (difference < _splashDuration) {
        await Future.delayed(_splashDuration - difference);
      }
      emit(state.copyWith(
        isSplashInitialized: true,
      ));
      _openHomePage();
    } catch (e) {
      emit(state.copyWith(
        initializationError: e.toString(),
      ));
      if (!kDebugMode) {
        emit(state.copyWith(
          initializationError: '',
        ));
      }
    }
  }

  void _openHomePage() async {
    emit(state.copyWith(openTheNextPage: true));
    emit(state.copyWith(openTheNextPage: false));
  }
}
