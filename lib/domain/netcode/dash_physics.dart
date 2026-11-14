// Shared, deterministic dash simulation.
//
// This file has a twin on the server: data/modules/functions/src/netcode/
// dash_physics.ts in the flappy_dash_nakama repo. Both must stay in sync,
// operation for operation, so that the client predicts its own dash and lands
// on exactly the numbers the server computes (doubles are IEEE 754 on both
// sides, so the same operations in the same order give the same bits).
//
// Every dash only interacts with the pipes (never with another dash) and the
// pipes are fixed for the whole match, so a dash's whole life is a pure
// function of its spawn point and the ticks its player jumped in.

class DashPhysics {
  DashPhysics._();

  static const int tickRate = 60;
  static const double dt = 1 / tickRate;

  static const double gravity = 1400.0;
  static const double jumpVelocity = -500.0;
  static const double dashSpeed = 160.0;

  static const double pipesDistance = 420.0;
  static const double pipeWidth = 82.0;
  static const double pipeHoleGap = 240.0;
  static const double pipesPositionArea = 300.0;

  // pipe.png is 247x2266, drawn 82 wide.
  static const double pipeHeight = pipeWidth * 2266 / 247;

  // The dash is 80x80, anchored at its center. Its hitbox is a circle of
  // radius 30 whose center sits 4px right of and below the dash's position.
  static const double dashHitboxRadius = 30.0;
  static const double dashHitboxOffset = 4.0;

  // The hidden coin of a pipe pair (you score when you touch it).
  static const double coinOffsetX = 30.0;
  static const double coinWidth = 40.0;
  static const double coinHeight = pipeHoleGap * 0.9;

  // The visible world is 1000 high (fixed resolution camera); leaving it
  // kills.
  static const double outOfBoundsY = 520.0;

  // Precomputed so both sides do the exact same floating point operations.
  static const double halfGravityDtSquared = 0.5 * gravity * dt * dt;
  static const double gravityDt = gravity * dt;
  static const double dashStep = dashSpeed * dt;

  /// Pipe k stands at x = k * pipesDistance (unwrapped coordinates); its gap
  /// center comes from the match's pipesPositions, repeating every
  /// pipesPositions.length pipes (the world loops).
  static double pipeGapCenterY(List<double> pipesPositions, int pipeIndex) {
    final n = pipesPositions.length;
    final i = (((pipeIndex - 1) % n) + n) % n;
    return pipesPositions[i] * pipesPositionArea;
  }

  static int pipeIndexAt(double x) => (x / pipesDistance + 0.5).floor();

  static bool _circleIntersectsRect(
    double cx,
    double cy,
    double r,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    final nearestX = cx < left ? left : (cx > right ? right : cx);
    final nearestY = cy < top ? top : (cy > bottom ? bottom : cy);
    final dx = cx - nearestX;
    final dy = cy - nearestY;
    return dx * dx + dy * dy < r * r;
  }

  /// Advances [sim] by one tick. [jump] is whether the player jumped in it.
  static DashStepResult step(
    DashSim sim,
    bool jump,
    List<double> pipesPositions,
  ) {
    if (!sim.alive) {
      return DashStepResult.none;
    }
    if (jump) {
      sim.vy = jumpVelocity;
    }
    // Exact for constant gravity, so the arc doesn't depend on the tick rate.
    sim.y = sim.y + sim.vy * dt + halfGravityDtSquared;
    sim.vy = sim.vy + gravityDt;
    sim.x = sim.x + dashStep;

    if (sim.y > outOfBoundsY || sim.y < -outOfBoundsY) {
      sim.alive = false;
      return DashStepResult.died;
    }

    final cx = sim.x + dashHitboxOffset;
    final cy = sim.y + dashHitboxOffset;
    const r = dashHitboxRadius;
    // Pipes are 420 apart and the hitbox only reaches 80px around a pipe's
    // center line, so only the nearest pipe can touch the dash.
    final k = (cx / pipesDistance + 0.5).floor();
    if (k < sim.firstPipe) {
      return DashStepResult.none;
    }
    final px = k * pipesDistance;
    final gapY = pipeGapCenterY(pipesPositions, k);
    const halfPipe = pipeWidth / 2;
    const halfGap = pipeHoleGap / 2;
    final hitsBottomPipe = _circleIntersectsRect(
      cx,
      cy,
      r,
      px - halfPipe,
      gapY + halfGap,
      px + halfPipe,
      gapY + halfGap + pipeHeight,
    );
    final hitsTopPipe = _circleIntersectsRect(
      cx,
      cy,
      r,
      px - halfPipe,
      gapY - halfGap - pipeHeight,
      px + halfPipe,
      gapY - halfGap,
    );
    if (hitsBottomPipe || hitsTopPipe) {
      sim.alive = false;
      return DashStepResult.died;
    }
    if (k > sim.lastScoredPipe) {
      final coinLeft = px + coinOffsetX - coinWidth / 2;
      final coinTop = gapY - coinHeight / 2;
      if (_circleIntersectsRect(
        cx,
        cy,
        r,
        coinLeft,
        coinTop,
        coinLeft + coinWidth,
        coinTop + coinHeight,
      )) {
        sim.lastScoredPipe = k;
        sim.score = sim.score + 1;
        return DashStepResult.scored;
      }
    }
    return DashStepResult.none;
  }
}

enum DashStepResult { none, scored, died }

class DashSim {
  DashSim({
    required this.x,
    required this.y,
    required this.vy,
    required this.alive,
    required this.score,
    required this.firstPipe,
    required this.lastScoredPipe,
  });

  /// A new life at a spawn point. The pipe the dash spawns on is ignored.
  factory DashSim.spawn(double spawnX, double spawnY, int score) {
    final spawnPipe = (spawnX / DashPhysics.pipesDistance + 0.5).floor();
    return DashSim(
      x: spawnX,
      y: spawnY,
      vy: 0,
      alive: true,
      score: score,
      firstPipe: spawnPipe + 1,
      lastScoredPipe: spawnPipe,
    );
  }

  /// Distance travelled since the spawn point, NOT wrapped around the world.
  double x;
  double y;
  double vy;
  bool alive;
  int score;

  /// Pipes with an index below this are ignored (the one the dash spawns on).
  int firstPipe;

  /// The highest pipe index whose coin was collected.
  int lastScoredPipe;

  DashSim copy() => DashSim(
    x: x,
    y: y,
    vy: vy,
    alive: alive,
    score: score,
    firstPipe: firstPipe,
    lastScoredPipe: lastScoredPipe,
  );

  @override
  String toString() =>
      'DashSim(x: $x, y: $y, vy: $vy, alive: $alive, score: $score, '
      'firstPipe: $firstPipe, lastScoredPipe: $lastScoredPipe)';
}
