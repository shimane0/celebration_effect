import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const double _defaultReferenceWidth = 360;
const double _defaultReferenceHeight = 690;
const double _defaultReferenceArea = _defaultReferenceWidth * _defaultReferenceHeight;

const double _minGravity = 0.04;
const double _maxGravity = 0.6;

const int _baseConfettiCount = 160;
const int _baseCrackerCount = 70;
const int _minConfettiCount = 90;
const int _maxConfettiCount = 260;
const int _minCrackerCount = 40;
const int _maxCrackerCount = 140;

const double _minConfettiSize = 6;
const double _maxConfettiSize = 18;
const double _minCrackerSize = 6;
const double _maxCrackerSize = 24;

const double _minConfettiMass = 1;
const double _maxConfettiMass = 8;
const double _minCrackerMass = 2;
const double _maxCrackerMass = 8;

const double _defaultConfettiGravity = 0.18;
const double _defaultCrackerGravity = 0.16;
const double _defaultConfettiDrag = 0.05;
const double _defaultCrackerDrag = 0.03;

const double _defaultMinBlastForce = 14;
const double _defaultMaxBlastForce = 32;

const double _defaultConfettiHorizontalSpread = 0.12;

const List<Color> _defaultColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.pink,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
];

/// 祝福演出コントローラー
///
/// 紙吹雪やクラッカーなどの演出を制御します。
class CelebrationController extends ChangeNotifier {
  CelebrationController({Duration duration = const Duration(seconds: 4)}) : _duration = duration;

  Duration _duration;
  bool _isPlaying = false;

  /// 演出が再生中かどうか
  bool get isPlaying => _isPlaying;

  /// 演出時間
  Duration get duration => _duration;

  /// 演出時間を更新
  void updateDuration({required Duration duration}) {
    if (_duration == duration) {
      return;
    }
    _duration = duration;
    notifyListeners();
  }

  /// 演出を開始
  void play({Duration? duration}) {
    if (duration != null) {
      _duration = duration;
    }
    _isPlaying = true;
    notifyListeners();
  }

  /// 演出を停止
  void stop() {
    if (!_isPlaying) {
      return;
    }
    _isPlaying = false;
    notifyListeners();
  }

  /// 演出を切り替え
  void toggle({Duration? duration}) {
    if (_isPlaying) {
      stop();
      return;
    }
    play(duration: duration);
  }
}

/// 子ウィジェットの上に演出を重ねるオーバーレイ
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.child,
    this.effects = const [],
    this.expandEffects = true,
    this.clipBehavior = Clip.none,
  });

  /// 背景として表示する子ウィジェット
  final Widget child;

  /// 上に重ねる演出ウィジェット
  final List<Widget> effects;

  /// 演出を子サイズに合わせて全域に展開するかどうか
  final bool expandEffects;

  /// オーバーレイのクリップ設定
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final overlayEffects = effects.map((effect) {
      if (!expandEffects || effect is Positioned) {
        return effect;
      }
      return Positioned.fill(child: effect);
    }).toList();

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: clipBehavior,
      children: [child, ...overlayEffects],
    );
  }
}

/// 紙吹雪演出ウィジェット
class ConfettiEffect extends StatelessWidget {
  const ConfettiEffect({
    super.key,
    required this.controller,
    this.numberOfParticles,
    this.gravity = _defaultConfettiGravity,
    this.particleDrag = _defaultConfettiDrag,
    this.colors,
    this.originAlignment = Alignment.topCenter,
    this.minParticleSize = _minConfettiSize,
    this.maxParticleSize = _maxConfettiSize,
    this.horizontalSpread = _defaultConfettiHorizontalSpread,
    this.referenceSize = const Size(360, 690),
    this.densityScale = 1,
  });

  /// 演出コントローラー
  final CelebrationController controller;

  /// パーティクル数（nullの場合は画面サイズから自動算出）
  final int? numberOfParticles;

  /// 重力（0.0〜1.0）。高いほど速く落ちる
  final double gravity;

  /// 空気抵抗（0.0〜1.0）。高いほど抵抗が大きい
  final double particleDrag;

  /// パーティクルの色
  final List<Color>? colors;

  /// パーティクル発生位置
  final Alignment originAlignment;

  /// パーティクルの最小サイズ
  final double minParticleSize;

  /// パーティクルの最大サイズ
  final double maxParticleSize;

  /// 画面幅に対する生成範囲の拡張率
  final double horizontalSpread;

  /// 自動スケーリングの基準サイズ
  final Size referenceSize;

  /// パーティクル密度の倍率
  final double densityScale;

  @override
  Widget build(BuildContext context) {
    return _CelebrationEffect(
      controller: controller,
      kind: _CelebrationKind.confetti,
      numberOfParticles: numberOfParticles,
      gravity: gravity,
      particleDrag: particleDrag,
      colors: colors,
      originAlignment: originAlignment,
      minParticleSize: minParticleSize,
      maxParticleSize: maxParticleSize,
      horizontalSpread: horizontalSpread,
      referenceSize: referenceSize,
      densityScale: densityScale,
    );
  }
}

/// クラッカー演出ウィジェット
class CrackerEffect extends StatelessWidget {
  const CrackerEffect({
    super.key,
    required this.controller,
    this.blastDirection,
    this.numberOfParticles,
    this.gravity = _defaultCrackerGravity,
    this.particleDrag = _defaultCrackerDrag,
    this.maxBlastForce = _defaultMaxBlastForce,
    this.minBlastForce = _defaultMinBlastForce,
    this.colors,
    this.originAlignment = Alignment.centerLeft,
    this.minParticleSize = _minCrackerSize,
    this.maxParticleSize = _maxCrackerSize,
    this.referenceSize = const Size(360, 690),
    this.densityScale = 1,
  });

  /// 演出コントローラー
  final CelebrationController controller;

  /// クラッカーの発射方向（ラジアン）。nullの場合は上方向に拡散
  final double? blastDirection;

  /// パーティクル数（nullの場合は画面サイズから自動算出）
  final int? numberOfParticles;

  /// 重力（0.0〜1.0）。高いほど速く落ちる
  final double gravity;

  /// 空気抵抗（0.0〜1.0）。高いほど抵抗が大きい
  final double particleDrag;

  /// 最大発射力
  final double maxBlastForce;

  /// 最小発射力
  final double minBlastForce;

  /// パーティクルの色
  final List<Color>? colors;

  /// パーティクル発生位置
  final Alignment originAlignment;

  /// パーティクルの最小サイズ
  final double minParticleSize;

  /// パーティクルの最大サイズ
  final double maxParticleSize;

  /// 自動スケーリングの基準サイズ
  final Size referenceSize;

  /// パーティクル密度の倍率
  final double densityScale;

  @override
  Widget build(BuildContext context) {
    return _CelebrationEffect(
      controller: controller,
      kind: _CelebrationKind.cracker,
      blastDirection: blastDirection,
      numberOfParticles: numberOfParticles,
      gravity: gravity,
      particleDrag: particleDrag,
      maxBlastForce: maxBlastForce,
      minBlastForce: minBlastForce,
      colors: colors,
      originAlignment: originAlignment,
      minParticleSize: minParticleSize,
      maxParticleSize: maxParticleSize,
      referenceSize: referenceSize,
      densityScale: densityScale,
    );
  }
}

enum _CelebrationKind { confetti, cracker }

class _CelebrationEffect extends StatefulWidget {
  const _CelebrationEffect({
    required this.controller,
    required this.kind,
    this.blastDirection,
    this.numberOfParticles,
    required this.gravity,
    required this.particleDrag,
    this.maxBlastForce = _defaultMaxBlastForce,
    this.minBlastForce = _defaultMinBlastForce,
    this.colors,
    required this.originAlignment,
    required this.minParticleSize,
    required this.maxParticleSize,
    this.horizontalSpread,
    required this.referenceSize,
    required this.densityScale,
  });

  final CelebrationController controller;
  final _CelebrationKind kind;
  final double? blastDirection;
  final int? numberOfParticles;
  final double gravity;
  final double particleDrag;
  final double maxBlastForce;
  final double minBlastForce;
  final List<Color>? colors;
  final Alignment originAlignment;
  final double minParticleSize;
  final double maxParticleSize;
  final double? horizontalSpread;
  final Size referenceSize;
  final double densityScale;

  @override
  State<_CelebrationEffect> createState() => _CelebrationEffectState();
}

class _CelebrationEffectState extends State<_CelebrationEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<_ConfettiParticle> _particles = [];
  final _random = math.Random();
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.controller.duration)
      ..addListener(_onTick)
      ..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _CelebrationEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _animationController.duration = widget.controller.duration;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.isPlaying) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.controller.stop();
    }
  }

  void _onTick() {
    final gravityForce = _resolveGravity();
    final drag = widget.particleDrag.clamp(0.0, 1.0);

    setState(() {
      for (final particle in _particles) {
        particle.update(gravityForce, drag);
      }
    });
  }

  double _resolveGravity() {
    final gravityValue = widget.gravity.clamp(0.0, 1.0);
    final baseGravity = lerpDouble(_minGravity, _maxGravity, gravityValue)!;
    return baseGravity * _resolveMotionScale();
  }

  void _startAnimation() {
    _animationController.duration = widget.controller.duration;
    if (_canvasSize != null) {
      _generateParticles(_canvasSize!);
    }
    _animationController.forward(from: 0);
  }

  void _stopAnimation() {
    _animationController.stop();
    setState(() {
      _particles = [];
    });
  }

  double _resolveMotionScale() {
    final size = _canvasSize;
    if (size == null) {
      return 1;
    }
    final shortestSide = size.shortestSide;
    final base = widget.referenceSize.shortestSide;
    final safeBase = base <= 0 ? _defaultReferenceWidth : base;
    return (shortestSide / safeBase).clamp(0.8, 1.6);
  }

  int _resolveParticleCount(Size size) {
    if (widget.numberOfParticles != null) {
      return widget.numberOfParticles!;
    }
    final baseArea = widget.referenceSize.width * widget.referenceSize.height;
    final safeArea = baseArea <= 0 ? _defaultReferenceArea : baseArea;
    final areaScale = (size.width * size.height) / safeArea;
    final density = widget.densityScale.clamp(0.5, 2.5);
    if (widget.kind == _CelebrationKind.confetti) {
      final scaled = (areaScale * _baseConfettiCount * density).round();
      return scaled.clamp(_minConfettiCount, _maxConfettiCount);
    }
    final scaled = (areaScale * _baseCrackerCount * density).round();
    return scaled.clamp(_minCrackerCount, _maxCrackerCount);
  }

  double _randomize(double min, double max) => lerpDouble(min, max, _random.nextDouble())!;

  void _generateParticles(Size size) {
    final colors = widget.colors ?? _defaultColors;
    final motionScale = _resolveMotionScale();
    final count = _resolveParticleCount(size);

    _particles = List.generate(count, (index) {
      final color = colors[_random.nextInt(colors.length)];
      final particleWidth =
          _randomize(widget.minParticleSize, widget.maxParticleSize) * motionScale;
      final particleHeight =
          _randomize(widget.minParticleSize * 0.7, widget.maxParticleSize * 0.8) * motionScale;

      if (widget.kind == _CelebrationKind.cracker) {
        final originX = size.width * (widget.originAlignment.x + 1) / 2;
        final originY = size.height * (widget.originAlignment.y + 1) / 2;

        final force = _randomize(widget.minBlastForce, widget.maxBlastForce) * motionScale;
        final angle = (widget.blastDirection ?? -math.pi / 2) + _randomize(-0.7, 0.7);

        final initialVelocityX = math.cos(angle) * force;
        final initialVelocityY = math.sin(angle) * force;

        final crackerWidth = _randomize(_minCrackerSize, _maxCrackerSize) * motionScale;
        final crackerHeight = _randomize(4, 10) * motionScale;

        return _ConfettiParticle(
          x: originX,
          y: originY,
          velocityX: initialVelocityX,
          velocityY: initialVelocityY,
          color: color,
          width: crackerWidth,
          height: crackerHeight,
          mass: _randomize(_minCrackerMass, _maxCrackerMass),
          angleX: _randomize(0, math.pi * 2),
          angleY: _randomize(0, math.pi * 2),
          angleZ: _randomize(0, math.pi * 2),
          angularVelocityX: _randomize(-0.25, 0.25),
          angularVelocityY: _randomize(-0.25, 0.25),
          angularVelocityZ: _randomize(-0.25, 0.25),
          initialBoostX: initialVelocityX * 0.3,
          initialBoostY: initialVelocityY * 0.3 - 2 * motionScale,
          boostFrames: _random.nextInt(8) + 5,
        );
      }

      final horizontalSpread = widget.horizontalSpread ?? _defaultConfettiHorizontalSpread;
      final startX = _randomize(
        -size.width * horizontalSpread,
        size.width * (1 + horizontalSpread),
      );
      final startY = _randomize(-size.height * 0.25, -size.height * 0.05);

      final velocityX = _randomize(-2, 2) * motionScale;
      final velocityY = _randomize(0.6, 2.2) * motionScale;

      return _ConfettiParticle(
        x: startX,
        y: startY,
        velocityX: velocityX,
        velocityY: velocityY,
        color: color,
        width: particleWidth,
        height: particleHeight,
        mass: _randomize(_minConfettiMass, _maxConfettiMass),
        angleX: _randomize(0, math.pi * 2),
        angleY: _randomize(0, math.pi * 2),
        angleZ: _randomize(0, math.pi * 2),
        angularVelocityX: _randomize(-0.08, 0.08),
        angularVelocityY: _randomize(-0.08, 0.08),
        angularVelocityZ: _randomize(-0.08, 0.08),
        rotateZ: _random.nextBool(),
        swayAmplitude: _randomize(0.6, 2.5) * motionScale,
        swayFrequency: _randomize(0.03, 0.08),
        swayPhase: _randomize(0, math.pi * 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        if (size.isEmpty) {
          return const SizedBox.shrink();
        }

        if (_canvasSize != size) {
          _canvasSize = size;
          if (widget.controller.isPlaying && _particles.isEmpty) {
            _generateParticles(size);
          }
        }

        if (_particles.isEmpty) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _animationController.value,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.width,
    required this.height,
    required this.mass,
    required this.angleX,
    required this.angleY,
    required this.angleZ,
    required this.angularVelocityX,
    required this.angularVelocityY,
    required this.angularVelocityZ,
    this.rotateZ = true,
    this.swayAmplitude = 0,
    this.swayFrequency = 0,
    this.swayPhase = 0,
    this.initialBoostX = 0,
    this.initialBoostY = 0,
    this.boostFrames = 0,
  });

  double x;
  double y;
  double velocityX;
  double velocityY;
  final Color color;
  final double width;
  final double height;
  final double mass;

  double angleX;
  double angleY;
  double angleZ;
  double angularVelocityX;
  double angularVelocityY;
  double angularVelocityZ;
  final bool rotateZ;

  final double swayAmplitude;
  final double swayFrequency;
  double swayPhase;

  final double initialBoostX;
  final double initialBoostY;
  int boostFrames;

  double _accelerationX = 0;
  double _accelerationY = 0;

  int _frameCount = 0;

  void update(double gravity, double drag) {
    _frameCount++;

    if (_frameCount <= boostFrames && boostFrames > 0) {
      _accelerationX += initialBoostX / mass;
      _accelerationY += initialBoostY / mass;
    }

    final speed = math.sqrt(velocityX * velocityX + velocityY * velocityY);
    if (speed > 0) {
      final dragMagnitude = drag * speed * speed;
      final dragX = -velocityX / speed * dragMagnitude / mass;
      final dragY = -velocityY / speed * dragMagnitude / mass;
      _accelerationX += dragX;
      _accelerationY += dragY;
    }

    _accelerationY += gravity;

    velocityX += _accelerationX;
    velocityY += _accelerationY;

    x += velocityX;
    y += velocityY;

    if (swayAmplitude > 0) {
      swayPhase += swayFrequency;
      x += math.sin(swayPhase) * swayAmplitude;
    }

    angleX += angularVelocityX;
    angleY += angularVelocityY;
    if (rotateZ) {
      angleZ += angularVelocityZ;
    }

    angularVelocityX *= 0.999;
    angularVelocityY *= 0.999;
    angularVelocityZ *= 0.999;

    _accelerationX = 0;
    _accelerationY = 0;
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final cosX = math.cos(particle.angleX);
      final sinX = math.sin(particle.angleX);
      final cosY = math.cos(particle.angleY);
      final sinY = math.sin(particle.angleY);
      final cosZ = particle.rotateZ ? math.cos(particle.angleZ) : 1.0;
      final sinZ = particle.rotateZ ? math.sin(particle.angleZ) : 0.0;

      final matrix = Matrix4(
        cosY * cosZ,
        cosX * sinZ + sinX * sinY * cosZ,
        sinX * sinZ - cosX * sinY * cosZ,
        0,
        -cosY * sinZ,
        cosX * cosZ - sinX * sinY * sinZ,
        sinX * cosZ + cosX * sinY * sinZ,
        0,
        sinY,
        -sinX * cosY,
        cosX * cosY,
        0.001,
        particle.x,
        particle.y,
        0,
        1,
      );

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(-particle.width, 0)
        ..lineTo(-particle.width, particle.height)
        ..lineTo(0, particle.height)
        ..close();

      final transformedPath = path.transform(matrix.storage);
      canvas.drawPath(transformedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }
}
