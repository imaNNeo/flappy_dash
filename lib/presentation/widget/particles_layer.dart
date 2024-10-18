import 'dart:async';
import 'dart:convert';

import 'package:flappy_dash/domain/extensions/color_extension.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:particular/particular.dart';

class ParticlesLayer extends StatefulWidget {
  const ParticlesLayer({super.key});

  @override
  State<ParticlesLayer> createState() => _ParticlesLayerState();
}

class _ParticlesLayerState extends State<ParticlesLayer> {
  final _particleController = ParticularController();

  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    _loadParticleAssets();
    _streamSubscription =
        context.read<GameCubit>().playerDiedAt.listen((event) {
      for (var layer in _particleController.layers) {
        layer.configs.startColor =
            AppColors.getDashParticleStartColor(event.$1).toARGB();
        layer.configs.startColorVariance =
            AppColors.getDashParticleStartColorVariance(event.$1);
        layer.configs.emitterX = event.$2;
        layer.configs.emitterY = event.$3;
      }
      _particleController.resetTick();
    });
    super.initState();
  }

  // Load configs and texture of particle
  Future<void> _loadParticleAssets() async {
    // Load particle configs file
    String json = await rootBundle.loadString(
      "assets/die_configs.json",
    );
    final configsData = jsonDecode(json) as List;

    // Load particle texture file
    _particleController.addLayer(
      configsData: configsData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Particular(
      controller: _particleController,
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
