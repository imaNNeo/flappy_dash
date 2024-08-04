part of 'splash_cubit.dart';

class SplashState with EquatableMixin {
  const SplashState({
    this.isLoading = false,
    this.openHomePage = false,
  });

  final bool isLoading;
  final bool openHomePage;

  SplashState copyWith({
    bool? isLoading,
    bool? openHomePage,
  }) =>
      SplashState(
        isLoading: isLoading ?? this.isLoading,
        openHomePage: openHomePage ?? this.openHomePage,
      );

  @override
  List<Object> get props => [
        isLoading,
        openHomePage,
      ];
}
