part of '../multiplayer_lobby_page.dart';

class PendingMatchBox extends StatelessWidget {
  const PendingMatchBox({
    super.key,
    required this.horizontalPadding,
    required this.screenSize,
  });

  final double horizontalPadding;
  final ScreenSize screenSize;

  @override
  Widget build(BuildContext context) {
    final lastWinnerHeight = switch (screenSize) {
      ScreenSize.extraSmall => 32.0,
      ScreenSize.small => 42.0,
      ScreenSize.medium => 52.0,
      ScreenSize.large || ScreenSize.extraLarge => 60.0,
    };
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      builder: (context, state) {
        return TransparentContentBox(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    PresentationUtils.formatSeconds(
                      state.matchWaitingRemainingSeconds,
                    ),
                    style: const TextStyle(
                      color: AppColors.whiteTextColor,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                    child: BigButton(
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
}
