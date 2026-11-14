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
    final screenSize = ScreenSize.fromContext(context);
    final timerRowHeight = switch (screenSize) {
      ScreenSize.extraSmall => 46.0,
      ScreenSize.small => 56.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 72.0,
    };
    final timerFontSize = switch (screenSize) {
      ScreenSize.extraSmall => 26.0,
      ScreenSize.small => 30.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 36.0,
    };
    final bottomGap = switch (screenSize) {
      ScreenSize.extraSmall => 10.0,
      ScreenSize.small => 16.0,
      ScreenSize.medium || ScreenSize.large || ScreenSize.extraLarge => 24.0,
    };
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The last winner badge sits on top of the box like a tab.
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: LastMatchWinnerWidget(height: lastWinnerHeight),
              ),
            ),
            Flexible(
              child: TransparentContentBox(
                margin: margin,
                child: Column(
                  children: [
                    SizedBox(
                      height: timerRowHeight,
                      child: Row(
                        children: [
                          SizedBox(width: horizontalPadding + 48),
                          Expanded(
                            child: Center(
                              child: Text(
                                PresentationUtils.formatSeconds(
                                  state.matchWaitingRemainingSeconds,
                                ),
                                style: TextStyle(
                                  color: AppColors.whiteTextColor,
                                  fontSize: timerFontSize,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: state.matchId.isNotBlank
                                ? IconButton(
                                    tooltip: 'Share lobby',
                                    icon: SvgPicture.asset(
                                      'assets/icons/ic_qr.svg',
                                      width: 28,
                                      height: 28,
                                    ),
                                    onPressed: () =>
                                        _shareLobby(context, state.matchId),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(width: horizontalPadding),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${state.inLobbyPlayers.length} Joined',
                            style: const TextStyle(
                              color: AppColors.whiteTextColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Divider(color: Colors.white24, thickness: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: state.inLobbyPlayers.isEmpty
                          ? const Center(
                              child: Text(
                                'Be the first to join!',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(
                                left: horizontalPadding,
                                right: horizontalPadding,
                                top: 4,
                                bottom: 12,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        screenSize == ScreenSize.extraLarge
                                        ? 220
                                        : 180,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
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
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final buttonWidth = min(
                            BigButton.defaultWidth(screenSize),
                            constraints.maxWidth - 2 * 52,
                          );
                          return Row(
                            children: [
                              SizedBox(
                                width: 52,
                                child: AutoJumpWidget(state: state),
                              ),
                              Expanded(
                                child: Center(
                                  child: BigButton(
                                    width: buttonWidth,
                                    strokeColor: Colors.white,
                                    bgColor: AppColors.blueButtonBgColor,
                                    onPressed: state.joinedInLobby
                                        ? null
                                        : () => _onJoinMatchPressed(context),
                                    child: Text(
                                      state.joinedInLobby ? 'JOINED' : 'JOIN',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 52,
                                child: BotControlsWidget(state: state),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: bottomGap),
                  ],
                ),
              ),
            ),
          ],
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
      // The new name reaches the account state a moment later; don't ask
      // for it again in the meantime.
      if (result.isNotNullOrBlank && context.mounted) {
        context.read<MultiplayerCubit>().joinLobby();
      }
      return;
    }
    context.read<MultiplayerCubit>().joinLobby();
  }

  void _shareLobby(BuildContext context, String matchId) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final url = '${AppConstants.baseUrl}$currentRoute';
    ShareQRContentDialog.show(context, title: 'Share Lobby', data: url);
  }
}
