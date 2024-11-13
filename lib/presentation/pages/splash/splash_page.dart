import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cubit/splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    context.read<SplashCubit>().onPageOpen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.openTheNextPage) {
          if (widget.redirectTo != null) {
            GoRouter.of(context).replace(widget.redirectTo!);
          } else {
            GoRouter.of(context).replace('/');
          }
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
