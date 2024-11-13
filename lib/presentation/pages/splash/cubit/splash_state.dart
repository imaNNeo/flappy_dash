part of 'splash_cubit.dart';

class SplashState with EquatableMixin {
  const SplashState({
    this.isLoading = false,
    this.openTheNextPage = false,
    this.isSplashInitialized = false,
  });

  final bool isLoading;
  final bool openTheNextPage;
  final bool isSplashInitialized;

  SplashState copyWith({
    bool? isLoading,
    bool? openTheNextPage,
    bool? isSplashInitialized,
  }) =>
      SplashState(
        isLoading: isLoading ?? this.isLoading,
        openTheNextPage: openTheNextPage ?? this.openTheNextPage,
        isSplashInitialized: isSplashInitialized ?? this.isSplashInitialized,
      );

  @override
  List<Object> get props => [
        isLoading,
        openTheNextPage,
        isSplashInitialized,
      ];
}
