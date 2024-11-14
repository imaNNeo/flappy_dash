part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.appVersion,
  });

  final (String, int)? appVersion;

  SettingsState copyWith({
    ValueWrapper<(String, int)?>? appVersion,
  }) =>
      SettingsState(
        appVersion: appVersion != null ? appVersion.value : this.appVersion,
      );

  @override
  List<Object?> get props => [
        appVersion,
      ];
}
