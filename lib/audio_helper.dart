import 'package:flutter_soloud/flutter_soloud.dart';

class AudioHelper {
  late AudioSource _bgMusicSource;
  late SoundHandle _bgMusicHandle;

  late AudioSource _scoreSoundSource;

  Future<void> initialize() async {
    await SoLoud.instance.init();
    _bgMusicSource = await SoLoud.instance.loadAsset(
      'assets/audio/bg-music.mp3',
    );
    _scoreSoundSource = await SoLoud.instance.loadAsset(
      'assets/audio/score.mp3',
    );
  }

  Future<void> playBackgroundMusic() async {
    _bgMusicHandle = await SoLoud.instance.play(
      _bgMusicSource,
      looping: true,
      volume: 2,
    );
  }

  Future<void> stopBackgroundMusic() async {
    SoLoud.instance.fadeVolume(
      _bgMusicHandle,
      0,
      const Duration(milliseconds: 700),
    );
  }

  Future<void> playScoreSound() async {
    await SoLoud.instance.play(_scoreSoundSource);
  }
}
