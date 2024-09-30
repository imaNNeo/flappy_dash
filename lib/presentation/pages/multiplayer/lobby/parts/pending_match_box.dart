part of '../multiplayer_lobby_page.dart';

class PendingMatchBox extends StatelessWidget {
  const PendingMatchBox({
    super.key,
    required this.horizontalPadding,
  });

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
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
                            itemCount: 17,
                            itemBuilder: (context, index) {
                              return DashPlayerBox(
                                playerName: 'Player $index',
                              );
                            },
                          ),
                          Transform.translate(
                            offset: Offset(horizontalPadding, -32),
                            child: const Text(
                              '17 Joined',
                              style: TextStyle(
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
                      onPressed: () {},
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
            ],
          ),
        );
      },
    );
  }
}
