import 'package:flappy_dash/presentation/extensions/build_context_extension.dart';
import 'package:flappy_dash/presentation/widget/app_version_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cubit/splash_cubit.dart';

import 'package:flappy_dash/presentation/helpers/update_helper/io_update_helper.dart'
    if (dart.library.js) 'package:flappy_dash/presentation/helpers/update_helper/web_update_helper.dart'
    if (dart.library.html) 'package:flappy_dash/presentation/helpers/update_helper/web_update_helper.dart';

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

        if (!kDebugMode && state.initializationError.isNotEmpty) {
          context.showToastError(state.initializationError);
        }

        if (state.versionIsOutdated) {
          _handleOutdatedVersion(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Container()),
                    if (kDebugMode) Text(state.initializationError),
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
                            style: TextStyle(
                                fontSize: 28, color: Color(0xFF25165F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: AppVersionWidget(),
              )
            ],
          ),
        );
      },
    );
  }

  void _handleOutdatedVersion(BuildContext context) async {
    await AppUpdateHelper.handleUpdateRequired(context);
  }
}
