enum PlayingState {
  idle,
  playing,
  gameOver,
  paused;

  bool get isPlaying => this == PlayingState.playing;

  bool get isNotPlaying => !isPlaying;

  bool get isGameOver => this == PlayingState.gameOver;

  bool get isNotGameOver => !isGameOver;

  bool get isIdle => this == PlayingState.idle;

  bool get isPaused => this == PlayingState.paused;
}
