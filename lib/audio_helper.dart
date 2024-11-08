import 'package:flutter_soloud/flutter_soloud.dart';

class AudioHelper {
  late SoLoud _soLoud;
  late AudioSource _backgroundSource;
  SoundHandle? _playingBackground;

  late AudioSource _scoreSource;

  bool get isPlayingBackgroundAudio => _playingBackground != null;

  Future<void> initialize() async {
    _soLoud = SoLoud.instance;
    await _soLoud.init();
    _backgroundSource = await _soLoud.loadAsset('assets/audio/background.mp3');
    _scoreSource = await _soLoud.loadAsset('assets/audio/score.mp3');
  }

  void playBackgroundAudio() async {
    _playingBackground = await _soLoud.play(_backgroundSource, looping: true);
    _soLoud.setProtectVoice(_playingBackground!, true);
  }

  void stopBackgroundAudio({bool immediately = false}) {
    if (_playingBackground == null) {
      return;
    }
    _soLoud.fadeVolume(
      _playingBackground!,
      0.0,
      Duration(milliseconds: immediately ? 0 : 500),
    );
  }

  void playScoreCollectSound() async {
    await _soLoud.play(_scoreSource);
  }
}
