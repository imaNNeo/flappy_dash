part of '../multiplayer_lobby_page.dart';

class PendingMatchBox extends StatelessWidget {
  const PendingMatchBox({
    super.key,
    required this.horizontalPadding,
    required this.lastWinnerHeight,
    required this.margin,
  });

  final double horizontalPadding;
  final double lastWinnerHeight;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        return TransparentContentBox(
          margin: margin,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 72,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: horizontalPadding),
                        Expanded(child: Container()),
                        Text(
                          PresentationUtils.formatSeconds(
                            state.matchWaitingRemainingSeconds,
                          ),
                          style: const TextStyle(
                            color: AppColors.whiteTextColor,
                            fontSize: 36,
                          ),
                        ),
                        Expanded(
                          child: state.matchId.isNotBlank
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/ic_qr.svg',
                                      ),
                                    ),
                                    onPressed: () =>
                                        _shareLobby(context, state.matchId),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(width: horizontalPadding),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: const Alignment(0, -0.5),
                      child: Stack(
                        fit: StackFit.loose,
                        alignment: Alignment.topLeft,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                              left: horizontalPadding,
                              right: horizontalPadding,
                              top: 0,
                              bottom: 32,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 174,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3,
                            ),
                            itemCount: state.inLobbyPlayers.length,
                            itemBuilder: (context, index) {
                              final player = state.inLobbyPlayers[index];
                              return DashPlayerBox(
                                playerUserId: player.userId,
                                playerName: player.displayName,
                                isMe: player.userId == state.currentUserId,
                              );
                            },
                          ),
                          Transform.translate(
                            offset: Offset(horizontalPadding, -32),
                            child: Text(
                              '${state.inLobbyPlayers.length} Joined',
                              style: const TextStyle(
                                color: AppColors.whiteTextColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoJumpWidget(state: state),
                        ),
                        BigButton(
                          strokeColor: Colors.white,
                          bgColor: AppColors.blueButtonBgColor,
                          onPressed: state.joinedInLobby
                              ? null
                              : () => _onJoinMatchPressed(context),
                          child: const Text(
                            'JOIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              Transform.translate(
                offset: Offset(18, -lastWinnerHeight),
                child: LastMatchWinnerWidget(
                  height: lastWinnerHeight,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _onJoinMatchPressed(BuildContext context) async {
    final currentAccount = context.read<AccountCubit>().state.currentAccount;
    if (currentAccount == null) {
      context.showToastError('Failed to get account information');
      return;
    }

    final doesNotHaveName = currentAccount.user.displayName.isNullOrBlank;
    if (doesNotHaveName) {
      final result = await NicknameDialog.show(context);
      if (result != null) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          _onJoinMatchPressed(context);
        }
      }
      return;
    }
    context.read<MultiplayerCubit>().joinLobby();
  }

  void _shareLobby(BuildContext context, String matchId) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final url = '${AppConstants.baseUrl}$currentRoute';
    ShareQRContentDialog.show(
      context,
      title: 'Share Lobby',
      data: url,
    );
  }
}
