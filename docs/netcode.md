# Multiplayer netcode

The server ([flappy_dash_nakama](https://github.com/imaNNeo/flappy_dash_nakama)) runs the
game: it decides where every dash is, when it scores and when it dies. Clients send only
their jumps. To keep the game feeling instant, it uses the techniques from Valve's
[Source Multiplayer Networking](https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking).

## Why this works well for Flappy Dash

A dash only collides with pipes, never with another dash, and the pipes are fixed once
the match starts. So a dash's whole life is a pure function of its spawn point and the
ticks its player jumped in. Client and server can run exactly the same simulation and
agree bit for bit.

## The pieces

| Source technique | In Flappy Dash | Code |
|---|---|---|
| Fixed tick rate | Each dash is simulated at 60 ticks/s with exact gravity integration, so a jump arc doesn't depend on the frame rate | `lib/domain/netcode/dash_physics.dart` ⇄ server `src/netcode/dash_physics.ts` |
| User commands | The client numbers its ticks (`seq`) and sends "my life started at tick L, I simulated up to tick N, I jumped at ticks [...]". It sends right away on a jump, otherwise a heartbeat every 3 ticks (~250 bytes/s). | `InputPacket` in `net_protocol.dart` |
| Server simulation | The server replays every player's commands on that player's own ticks and decides score, death and respawn | `simulatePlayer` in `multi_dash_handler.ts` |
| Snapshots and delta compression | The match loop runs at 20 Hz (it was 60) and sends one binary snapshot per loop with only the players that changed (22 bytes each), plus a full one every second | `Snapshot` in `net_protocol.dart` |
| Client-side prediction | Your own dash moves the moment you tap. When a snapshot acknowledges tick N, the client replays its unacknowledged jumps on top of the server state. A mismatch is corrected and smoothed out over ~100 ms. | `dash_predictor.dart` |
| Entity interpolation | Other dashes are drawn ~133 ms (8 ticks) in the past, between two server states, on their player's tick timeline. If the next state is late, the client extrapolates for up to 250 ms. | `remote_dash_interpolator.dart` |
| Lag compensation | A jump counts at the tick you pressed it, not when it reached the server. The end of the match is also judged in each player's own time: inputs from before the buzzer still count if they arrive within 350 ms. | `finishSeqOf` in `multi_dash_handler.ts` |

Since the server no longer trusts clients, it also:
- caps how far ahead of real time a client may run (speed hacks), and
- keeps simulating a client that goes quiet, with no jumps, so a frozen or disconnected
  player falls instead of hanging in the air.

## Keeping client and server in sync

`dash_physics.dart` and `dash_physics.ts` must do the same floating point operations in the
same order. `test/netcode/dash_physics_parity_test.dart` replays trajectories computed by
the server code (`tests/physics/physics_golden.json` in the server repo) and checks them
bit for bit. After a deliberate physics change, regenerate the golden file on the server
(`node tests/physics/golden.mjs > tests/physics/physics_golden.json`) and copy it here.

## Coordinates

The server and the prediction work in *unwrapped* x: the distance since the spawn point.
Pipe `k` stands at `x = k * 420` and uses `pipesPositions[(k - 1) % pipesCount]`. The world
still loops on screen: the client places other dashes on the copy of the world that is
nearest to your dash.
