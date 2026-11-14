import 'dart:ui';

/// How the eyes are drawn.
enum DashEyeShape {
  /// Regular round eyes with pupils (they can blink, look around, etc.).
  open,

  /// Closed happy eyes: ^ ^
  happy,

  /// Knocked out: X X
  dizzy,
}

/// Everything about a dash's pose and face that can change from frame to
/// frame. [DashPainter] draws it, [DashFaceAnimator] animates it.
///
/// All values are in the drawing's own units, where the whole character is
/// [DashPainter.canvasSize] wide (so they don't depend on the size on screen).
class DashFace {
  DashFace();

  DashEyeShape eyeShape = DashEyeShape.open;

  /// 1 is fully open, 0 is closed (blinking).
  double eyeOpen = 1;

  /// Scales the eye whites (1 is normal, > 1 is wide open).
  double eyeScale = 1;

  /// Scales the pupils (< 1 is tiny scared pupils).
  double pupilScale = 1;

  /// Where the pupils look, each axis in -1..1 (positive y is down).
  Offset look = Offset.zero;

  /// Moves the brows up (positive) or down (negative), in drawing units.
  double browLift = 0;

  /// Rotates the brows, in radians. Positive raises the inner side
  /// (worried), negative lowers it (determined / angry).
  double browTilt = 0;

  /// 0 is closed, 1 is wide open.
  double beakOpen = 0;

  /// 0..1, the pink cheeks.
  double blush = 0;

  /// 0..1, a sweat drop on the forehead.
  double sweat = 0;

  /// The front wing's rotation in radians (positive raises it).
  double wingAngle = 0;

  void copyFrom(DashFace other) {
    eyeShape = other.eyeShape;
    eyeOpen = other.eyeOpen;
    eyeScale = other.eyeScale;
    pupilScale = other.pupilScale;
    look = other.look;
    browLift = other.browLift;
    browTilt = other.browTilt;
    beakOpen = other.beakOpen;
    blush = other.blush;
    sweat = other.sweat;
    wingAngle = other.wingAngle;
  }
}
