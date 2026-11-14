import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Feathers flying out of a dash when it dies, then fluttering down,
/// plus a quick ring of white puffs.
///
/// The feathers come from a small sprite sheet drawn once from the feather
/// path ([loadSprites]) and are all drawn with a single [Canvas.drawAtlas].
/// Drawing each feather as a path (outline, fill and quill, every frame,
/// each at a new angle) made the GPU rasterize ~130 path masks per frame and
/// compile programs for them on the first death, which froze the first
/// frames of the death on the web.
class FeatherBurst extends PositionComponent {
  FeatherBurst({
    required super.position,
    required this.color,
    this.count = 18,
    this.scaleFactor = 1,
    Random? random,
    super.priority,
  }) : _random = random ?? Random();

  final Color color;
  final int count;
  final double scaleFactor;
  final Random _random;

  final List<_Feather> _feathers = [];
  final List<_Puff> _puffs = [];
  double _time = 0;
  static const _lifetime = 1.8;

  late final Paint _featherPaint;
  late final Paint _lightFeatherPaint;
  late final Paint _quillPaint;
  late final Paint _outlinePaint;
  final Paint _puffPaint = Paint();

  static final Path _featherPath = _buildFeatherPath();

  /// The sprite sheet, once [loadSprites] is done. Until then (or if it
  /// fails) the feathers are drawn as paths.
  static Image? _sprites;
  static Future<void>? _loadingSprites;

  /// Texture pixels per feather-path unit at a sprite's nominal size.
  static const _spriteResolution = 3.0;

  /// Feathers are 0.65..2.2 in size. Each one uses the sprite drawn at the
  /// nearest of these sizes, so the outline stays about as thick as it
  /// was drawn as a path (2.2 px whatever the feather's size).
  static const _spriteSizes = [0.85, 1.35, 1.9];

  /// One sprite cell, in feather-path units: the vane, its outline and the
  /// quill (x -15..13, y -7..6) with some room around them.
  static const _cellWidth = 32.0;
  static const _cellHeight = 18.0;
  static const _cellPadding = 4.0;

  /// The vane: white, outlined in 45% grey. Tinting it with the dash's
  /// color (BlendMode.modulate) gives the fill in that color and the
  /// outline in the color darkened by 55%, the same as the path version.
  static Rect _bodySprite(int sizeIndex) => _cellRect(sizeIndex, 0);

  /// The quill, white, drawn on top of the vane.
  static Rect _quillSprite(int sizeIndex) => _cellRect(sizeIndex, 1);

  static Rect _cellRect(int sizeIndex, int column) {
    final scale = _spriteSizes[sizeIndex] * _spriteResolution;
    final w = _cellWidth * scale;
    final h = _cellHeight * scale;
    var top = _cellPadding;
    for (var i = 0; i < sizeIndex; i++) {
      top += _cellHeight * _spriteSizes[i] * _spriteResolution + _cellPadding;
    }
    final left =
        _cellPadding +
        column *
            (_cellWidth * _spriteSizes.last * _spriteResolution + _cellPadding);
    return Rect.fromLTWH(left, top, w, h);
  }

  /// Draws the feather sprite sheet. Call it while the game loads; it is
  /// done once per app run.
  static Future<void> loadSprites() => _loadingSprites ??= _loadSprites();

  static Future<void> _loadSprites() async {
    try {
      final last = _cellRect(_spriteSizes.length - 1, 1);
      final width = (last.right + _cellPadding).ceil();
      final height = (last.bottom + _cellPadding).ceil();
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final fill = Paint()..color = const Color(0xFFFFFFFF);
      final outline = Paint()
        ..color =
            const Color(0xFF737373) // 0.45 grey
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final quill = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < _spriteSizes.length; i++) {
        final size = _spriteSizes[i];
        final scale = size * _spriteResolution;
        final body = _bodySprite(i);
        canvas.save();
        canvas.translate(body.center.dx, body.center.dy);
        canvas.scale(scale);
        outline.strokeWidth = 2.2 / size;
        canvas.drawPath(_featherPath, outline);
        canvas.drawPath(_featherPath, fill);
        canvas.restore();
        final quillRect = _quillSprite(i);
        canvas.save();
        canvas.translate(quillRect.center.dx, quillRect.center.dy);
        canvas.scale(scale);
        canvas.drawLine(const Offset(-15, 0.5), const Offset(11, -0.5), quill);
        canvas.restore();
      }
      final picture = recorder.endRecording();
      _sprites = await picture.toImage(width, height);
      picture.dispose();
    } catch (_) {
      // Paths it is.
    }
  }

  // Reused every frame by the atlas draw.
  List<RSTransform> _transforms = const [];
  List<Rect> _rects = const [];
  List<Color> _colors = const [];
  late final Color _lightColor;
  final Paint _atlasPaint = Paint()..filterQuality = FilterQuality.medium;

  static Path _buildFeatherPath() {
    // A leaf-like vane, pointing right, about 26 x 10.
    return Path()
      ..moveTo(-13, 0)
      ..quadraticBezierTo(-4, -7, 13, -1)
      ..quadraticBezierTo(4, 6, -13, 0)
      ..close();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _init();
  }

  /// Draws a burst, early and late in its life, without adding it to the
  /// game. The caller makes it invisible (e.g. in a near-transparent layer);
  /// it only makes the GPU compile what a real burst needs ahead of time.
  static void rehearse(Canvas canvas, Color color) {
    final burst = FeatherBurst(position: Vector2.zero(), color: color).._init();
    // The same moments a real burst goes through: fully opaque at first,
    // mid-flight, then fading.
    for (final dt in [0.0, 1 / 60, 0.3, 1.0]) {
      burst.update(dt);
      burst.render(canvas);
    }
  }

  void _init() {
    _featherPaint = Paint()..color = color;
    // Two strong shades, no pale ones (pale feathers vanish against the
    // sky), each with a thin dark outline so they read on any background.
    _lightColor = Color.lerp(color, const Color(0xFF0A4D8C), 0.45)!;
    _lightFeatherPaint = Paint()..color = _lightColor;
    _outlinePaint = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.55)!
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    _quillPaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;
      // Every third feather is a small, slower one that hangs around the
      // impact, so the burst reads as a cloud and not just a ring.
      final small = i % 3 == 2;
      final speed =
          (small
              ? 90 + _random.nextDouble() * 200
              : 180 + _random.nextDouble() * 380) *
          scaleFactor;
      _feathers.add(
        _Feather(
          x: 0,
          y: 0,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 120 * scaleFactor,
          rotation: _random.nextDouble() * pi * 2,
          spin: (_random.nextDouble() - 0.5) * 14,
          swayPhase: _random.nextDouble() * pi * 2,
          swaySpeed: 4 + _random.nextDouble() * 4,
          size:
              (small
                  ? 0.65 + _random.nextDouble() * 0.5
                  : 1.1 + _random.nextDouble() * 1.1) *
              scaleFactor,
          light: _random.nextBool(),
        ),
      );
    }
    for (var i = 0; i < 8; i++) {
      final angle = i / 8 * pi * 2 + _random.nextDouble() * 0.3;
      _puffs.add(
        _Puff(
          dx: cos(angle),
          dy: sin(angle),
          speed: (140 + _random.nextDouble() * 60) * scaleFactor,
          radius: (10 + _random.nextDouble() * 8) * scaleFactor,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_time >= _lifetime) {
      removeFromParent();
      return;
    }
    // Feathers: fast burst slowed by strong drag, then they drift down
    // slowly, swaying side to side like real feathers.
    final drag = exp(-3.2 * dt);
    for (final f in _feathers) {
      f.vx *= drag;
      f.vy = f.vy * drag + 260 * dt;
      // Terminal velocity: feathers fall slowly.
      f.vy = min(f.vy, 120.0);
      final sway = sin(_time * f.swaySpeed + f.swayPhase);
      f.x += (f.vx + sway * 60) * dt;
      f.y += f.vy * dt;
      f.rotation += f.spin * dt * (0.3 + 0.7 * drag) + sway * dt * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final t = _time / _lifetime;
    if (t >= 1) {
      return;
    }

    // Puff ring, first 0.35s.
    final puffT = (_time / 0.35).clamp(0.0, 1.0);
    if (puffT < 1) {
      final ease = 1 - pow(1 - puffT, 3).toDouble();
      _puffPaint.color = Color.fromRGBO(255, 255, 255, (1 - puffT) * 0.9);
      for (final p in _puffs) {
        final d = p.speed * 0.35 * ease;
        canvas.drawCircle(
          Offset(p.dx * d, p.dy * d),
          p.radius * (1 - puffT * 0.6),
          _puffPaint,
        );
      }
    }

    // Feathers fade out over the last 40% of their life.
    final alpha = (1 - (t - 0.6) / 0.4).clamp(0.0, 1.0);
    final sprites = _sprites;
    if (sprites != null) {
      _renderSprites(canvas, sprites, alpha);
    } else {
      _renderPaths(canvas, alpha);
    }
  }

  void _renderSprites(Canvas canvas, Image sprites, double alpha) {
    final n = _feathers.length * 2;
    if (_transforms.length != n) {
      _transforms = List.filled(n, RSTransform(1, 0, 0, 0));
      _rects = List.filled(n, Rect.zero);
      _colors = List.filled(n, const Color(0x00000000));
    }
    final dark = color.withValues(alpha: alpha);
    final light = _lightColor.withValues(alpha: alpha);
    final quill = Color.fromRGBO(255, 255, 255, 0.5 * alpha);
    var i = 0;
    for (final f in _feathers) {
      final sizeIndex = f.size < 1.1 ? 0 : (f.size < 1.62 ? 1 : 2);
      final scale = f.size / (_spriteSizes[sizeIndex] * _spriteResolution);
      final body = _bodySprite(sizeIndex);
      final quillRect = _quillSprite(sizeIndex);
      final transform = RSTransform.fromComponents(
        rotation: f.rotation,
        scale: scale,
        anchorX: body.width / 2,
        anchorY: body.height / 2,
        translateX: f.x,
        translateY: f.y,
      );
      _transforms[i] = transform;
      _rects[i] = body;
      _colors[i] = f.light ? light : dark;
      i++;
      _transforms[i] = transform;
      _rects[i] = quillRect;
      _colors[i] = quill;
      i++;
    }
    canvas.drawAtlas(
      sprites,
      _transforms,
      _rects,
      _colors,
      BlendMode.modulate,
      null,
      _atlasPaint,
    );
  }

  void _renderPaths(Canvas canvas, double alpha) {
    _featherPaint.color = color.withValues(alpha: alpha);
    _lightFeatherPaint.color = _lightFeatherPaint.color.withValues(
      alpha: alpha,
    );
    _quillPaint.color = Color.fromRGBO(255, 255, 255, 0.5 * alpha);
    _outlinePaint.color = _outlinePaint.color.withValues(alpha: alpha);
    for (final f in _feathers) {
      canvas.save();
      canvas.translate(f.x, f.y);
      canvas.rotate(f.rotation);
      canvas.scale(f.size);
      // About 2.2 px wide whatever the feather's size.
      _outlinePaint.strokeWidth = 2.2 / f.size;
      canvas.drawPath(_featherPath, _outlinePaint);
      canvas.drawPath(
        _featherPath,
        f.light ? _lightFeatherPaint : _featherPaint,
      );
      canvas.drawLine(
        const Offset(-15, 0.5),
        const Offset(11, -0.5),
        _quillPaint,
      );
      canvas.restore();
    }
  }
}

class _Feather {
  _Feather({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.spin,
    required this.swayPhase,
    required this.swaySpeed,
    required this.size,
    required this.light,
  });

  double x, y, vx, vy, rotation;
  final double spin, swayPhase, swaySpeed, size;
  final bool light;
}

class _Puff {
  _Puff({
    required this.dx,
    required this.dy,
    required this.speed,
    required this.radius,
  });

  final double dx, dy, speed, radius;
}
