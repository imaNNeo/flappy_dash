import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/entities/value_wrapper.dart';
import 'package:flappy_dash/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._settingsRepository,
  ) : super(const SettingsState()) {
    _initialize();
  }

  final SettingsRepository _settingsRepository;

  Future<void> _initialize() async {
    final appVersion = await _settingsRepository.getAppVersion();
    emit(state.copyWith(
      appVersion: ValueWrapper(appVersion),
    ));
  }
}
