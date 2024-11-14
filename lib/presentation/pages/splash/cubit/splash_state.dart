part of 'splash_cubit.dart';

class SplashState with EquatableMixin {
  const SplashState({
    this.isLoading = false,
    this.openTheNextPage = false,
    this.isSplashInitialized = false,
    this.initializationError = '',
    this.versionIsOutdated = false,
  });

  final bool isLoading;
  final bool openTheNextPage;
  final bool isSplashInitialized;
  final String initializationError;
  final bool versionIsOutdated;

  SplashState copyWith({
    bool? isLoading,
    bool? openTheNextPage,
    bool? isSplashInitialized,
    String? initializationError,
    bool? versionIsOutdated,
  }) =>
      SplashState(
        isLoading: isLoading ?? this.isLoading,
        openTheNextPage: openTheNextPage ?? this.openTheNextPage,
        isSplashInitialized: isSplashInitialized ?? this.isSplashInitialized,
        initializationError: initializationError ?? this.initializationError,
        versionIsOutdated: versionIsOutdated ?? this.versionIsOutdated,
      );

  @override
  List<Object> get props => [
        isLoading,
        openTheNextPage,
        isSplashInitialized,
        initializationError,
        versionIsOutdated,
      ];
}
