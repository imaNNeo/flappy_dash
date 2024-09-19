import 'package:flappy_dash/domain/repositories/game_repository.dart';
import 'package:flappy_dash/presentation/pages/main_page.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(getIt.get<GameRepository>()),
      child: const SplashPageContent(),
    );
  }
}

class SplashPageContent extends StatefulWidget {
  const SplashPageContent({super.key});

  @override
  State<SplashPageContent> createState() => _SplashPageContentState();
}

class _SplashPageContentState extends State<SplashPageContent> {

  @override
  void initState() {
    context.read<SplashCubit>().onPageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.openHomePage) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/dash.png',
                  width: 124,
                  height: 124,
                ),
                const Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Flappy Dash',
                        style:
                        TextStyle(fontSize: 28, color: Color(0xFF25165F)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
