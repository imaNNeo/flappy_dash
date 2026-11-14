import 'package:flappy_dash/domain/repositories/multiplayer_repository.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/presentation/responsive/screen_size.dart';
import 'package:flappy_dash/presentation/widget/app_version_widget.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/blurred_background.dart';
import 'package:flappy_dash/presentation/widget/game_title.dart';
import 'package:flappy_dash/presentation/widget/github_button.dart';
import 'package:flappy_dash/presentation/widget/gradient_text.dart';
import 'package:flappy_dash/presentation/widget/outline_text.dart';
import 'package:flappy_dash/presentation/widget/profile_overlay.dart';
import 'package:flappy_dash/presentation/widget/watch_on_youtube_widget.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flappy_dash/presentation/widget/fit_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'cubit/home_cubit.dart';

part 'parts/single_player_button.dart';

part 'parts/multi_player_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          HomeCubit(getIt.get<MultiplayerRepository>()),
      child: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void didChangeDependencies() {
    context.read<MultiplayerCubit>().refreshLastMatchOverview();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.fromContext(context);
    final titleBottomSpace = switch (screenSize) {
      ScreenSize.extraSmall => 16.0,
      ScreenSize.small => 24.0,
      ScreenSize.medium => 32.0,
      ScreenSize.large => 40.0,
      ScreenSize.extraLarge => 48.0,
    };
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.openMultiplayerLobby.isNotEmpty) {
          context.go('/lobby/${state.openMultiplayerLobby}');
        }
        if (state.multiPlayerMatchIdError.isNotEmpty) {
          context.showToastError(state.multiPlayerMatchIdError);
        }
      },
      builder: (context, state) {
        final shortLandscape = context.isShortLandscape;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const BlurredBackground(),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: PresentationConstants.defaultPadding / 2,
                        right: PresentationConstants.defaultPadding,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GithubButton(screenSize: screenSize),
                          const Spacer(),
                          const ProfileOverlay(),
                        ],
                      ),
                    ),
                    // Title and the play buttons always fit: on short
                    // screens they scale down instead of running off-screen.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PresentationConstants.defaultPadding,
                          vertical: 8,
                        ),
                        child: FitContent(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GameTitle(screenSize: screenSize),
                              SizedBox(height: titleBottomSpace),
                              SinglePlayerButton(
                                onPressed: () => context.push('/single_player'),
                              ),
                              SizedBox(height: shortLandscape ? 14 : 20),
                              MultiPlayerButton(
                                onPressed: context
                                    .read<HomeCubit>()
                                    .onMultiPlayerButtonPressed,
                                showLoading: state.multiPlayerMatchIdLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    WatchOnYoutubeWidget(screenSize: screenSize),
                    SizedBox(height: shortLandscape ? 4 : 16),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: AppVersionWidget(),
              ),
            ],
          ),
        );
      },
    );
  }
}
