part of 'splash_cubit.dart';

class SplashState with EquatableMixin {
  const SplashState({
    this.isLoading = false,
    this.openTheNextPage = false,
    this.isSplashInitialized = false,
    this.initializationError = '',
  });

  final bool isLoading;
  final bool openTheNextPage;
  final bool isSplashInitialized;
  final String initializationError;

  SplashState copyWith({
    bool? isLoading,
    bool? openTheNextPage,
    bool? isSplashInitialized,
    String? initializationError,
  }) =>
      SplashState(
        isLoading: isLoading ?? this.isLoading,
        openTheNextPage: openTheNextPage ?? this.openTheNextPage,
        isSplashInitialized: isSplashInitialized ?? this.isSplashInitialized,
        initializationError: initializationError ?? this.initializationError,
      );

  @override
  List<Object> get props => [
        isLoading,
        openTheNextPage,
        isSplashInitialized,
        initializationError,
      ];
}
