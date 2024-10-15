enum MultiplayerDiedMessage {
  message1(
    header: 'Pipes: 1, You: 0.',
    body: 'Respawning in X seconds…',
    onlyForZeroScore: true,
  ),
  message2(
    header: 'Piped!',
    body: 'Try again in X seconds…',
  ),
  message3(
    header: 'Outplayed by a pipe.',
    body: 'Respawning in X seconds!',
  ),
  message4(
    header: 'Another pipe victory…',
    body: 'X seconds to respawn.',
  ),
  message5(
    header: 'The pipe strikes back!',
    body: 'X seconds to go…',
  ),
  message6(
    header: 'Ouch, pipe!',
    body: 'Respawn in X seconds…',
  ),
  message7(
    header: 'Pipes are tough!',
    body: 'You’ll be back in X seconds…',
  ),
  message8(
    header: 'Piped out!',
    body: 'X seconds till you’re back…',
  ),
  message9(
    header: 'Pipes are relentless!',
    body: 'Respawn in X seconds…',
  ),
  message10(
    header: 'Pipe wins. Again.',
    body: 'Respawn in X seconds…',
  ),
  message11(
    header: 'That pipe is unbeatable.',
    body: 'Back in X seconds…',
  ),
  message12(
    header: 'Oops. Pipe strikes again.',
    body: 'Respawn in X seconds…',
  ),
  message13(
    header: 'Better luck next time?',
    body: 'X seconds to respawn…',
  ),
  message14(
    header: 'Pipes > You.',
    body: 'Respawning in X seconds…',
  ),
  message15(
    header: 'Not again…',
    body: 'X seconds till you’re back…',
  ),
  message16(
    header: 'The pipe prevails!',
    body: 'Respawn in X seconds…',
  ),
  message17(
    header: 'Pipe: unstoppable.',
    body: 'X seconds to respawn…',
  );

  final String header;
  final String _body;
  final bool onlyForZeroScore;

  String getBody(int seconds) => _body.replaceFirst('X', seconds.toString());

  const MultiplayerDiedMessage({
    required this.header,
    required String body,
    this.onlyForZeroScore = false,
  }) : _body = body;
}