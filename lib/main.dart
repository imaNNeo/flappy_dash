import 'package:device_preview/device_preview.dart';
import 'package:flappy_dash/presentation/pages/debug/debug_panel.dart';
import 'package:flappy_dash/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentation/app_routes.dart';
import 'presentation/app_style.dart';
import 'presentation/bloc/bloc_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(DevicePreview(
    enabled: kDebugMode,
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocRegistry(
      child: MaterialApp.router(
        routerConfig: AppRoutes.router,
        title: 'Flappy Dash',
        builder: (context, child) {
          return Stack(
            children: [
              DevicePreview.appBuilder(context, child),
              const Align(
                alignment: Alignment.bottomLeft,
                child: DebugPanel(),
              ),
            ],
          );
        },
        theme: ThemeData(
          fontFamily: 'Chewy',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.blueColor,
          ),
        ),
      ),
    );
  }
}
