part of 'home_cubit.dart';

class HomeState with EquatableMixin {
  final bool multiPlayerMatchIdLoading;
  final String multiPlayerMatchIdError;
  final String openMultiplayerLobby;

  HomeState({
    this.multiPlayerMatchIdLoading = false,
    this.multiPlayerMatchIdError = '',
    this.openMultiplayerLobby = '',
  });

  HomeState copyWith({
    bool? multiPlayerMatchIdLoading,
    String? multiPlayerMatchIdError,
    String? openMultiplayerLobby,
  }) =>
      HomeState(
        multiPlayerMatchIdLoading:
            multiPlayerMatchIdLoading ?? this.multiPlayerMatchIdLoading,
        multiPlayerMatchIdError:
            multiPlayerMatchIdError ?? this.multiPlayerMatchIdError,
        openMultiplayerLobby: openMultiplayerLobby ?? this.openMultiplayerLobby,
      );

  @override
  List<Object> get props => [
        multiPlayerMatchIdLoading,
        multiPlayerMatchIdError,
        openMultiplayerLobby,
      ];
}
