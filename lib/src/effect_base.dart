import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'celebration_controller.dart';
import 'celebration_painter.dart';
import 'constants.dart' as c;
import 'particle.dart';
import 'particle_shape.dart';

/// 演出の種類（内部使用）
enum CelebrationKind {
  /// 紙吹雪（上部から降り注ぐ）
  confetti,

  /// クラッカー（指定位置から発射）
  cracker,
}

/// 紙吹雪・クラッカー共通の演出基底ウィジェット（内部使用）
///
/// このクラスはパッケージ外部からの直接使用は想定していません。
/// `ConfettiEffect` または `CrackerEffect` を使用してください。
class CelebrationEffectWidget extends StatefulWidget {
  const CelebrationEffectWidget({
    super.key,
    required this.controller,
    required this.kind,
    this.blastDirection,
    this.numberOfParticles,
    required this.gravity,
    required this.particleDrag,
    this.maxBlastForce = c.defaultMaxBlastForce,
    this.minBlastForce = c.defaultMinBlastForce,
    this.colors,
    required this.originAlignment,
    required this.minParticleSize,
    required this.maxParticleSize,
    this.horizontalSpread,
    required this.referenceSize,
    required this.densityScale,
    this.shapes = const [ParticleShape.rectangle],
    this.fadeOutBegin = c.defaultFadeOutBegin,
    this.windForce = 0,
  });

  final CelebrationController controller;
  final CelebrationKind kind;
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
  final List<ParticleShape> shapes;
  final double fadeOutBegin;
  final double windForce;

  @override
  State<CelebrationEffectWidget> createState() => _CelebrationEffectWidgetState();
}

class _CelebrationEffectWidgetState extends State<CelebrationEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<Particle> _particles = [];
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
  void didUpdateWidget(covariant CelebrationEffectWidget oldWidget) {
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

  // ---------------------------------------------------------------------------
  // コントローラー・アニメーション連携
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    if (widget.controller.isPlaying) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.controller.notifyComplete();
    }
  }

  // ---------------------------------------------------------------------------
  // 物理シミュレーション
  // ---------------------------------------------------------------------------

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
    final baseGravity = lerpDouble(c.minGravity, c.maxGravity, gravityValue)!;
    return baseGravity * _resolveMotionScale();
  }

  double _resolveMotionScale() {
    final size = _canvasSize;
    if (size == null) {
      return 1;
    }
    final shortestSide = size.shortestSide;
    final base = widget.referenceSize.shortestSide;
    final safeBase = base <= 0 ? c.defaultReferenceWidth : base;
    return (shortestSide / safeBase).clamp(0.8, 1.6);
  }

  // ---------------------------------------------------------------------------
  // パーティクル生成
  // ---------------------------------------------------------------------------

  int _resolveParticleCount(Size size) {
    if (widget.numberOfParticles != null) {
      return widget.numberOfParticles!;
    }
    final baseArea = widget.referenceSize.width * widget.referenceSize.height;
    final safeArea = baseArea <= 0 ? c.defaultReferenceArea : baseArea;
    final areaScale = (size.width * size.height) / safeArea;
    final density = widget.densityScale.clamp(0.5, 2.5);

    if (widget.kind == CelebrationKind.confetti) {
      return (areaScale * c.baseConfettiCount * density).round().clamp(
        c.minConfettiCount,
        c.maxConfettiCount,
      );
    }
    return (areaScale * c.baseCrackerCount * density).round().clamp(
      c.minCrackerCount,
      c.maxCrackerCount,
    );
  }

  double _randomize(double min, double max) => lerpDouble(min, max, _random.nextDouble())!;

  ParticleShape _randomShape() {
    final shapes = widget.shapes;
    if (shapes.isEmpty) {
      return ParticleShape.rectangle;
    }
    return shapes[_random.nextInt(shapes.length)];
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
    setState(() => _particles = []);
  }

  void _generateParticles(Size size) {
    final colors = widget.colors ?? c.defaultColors;
    final motionScale = _resolveMotionScale();
    final count = _resolveParticleCount(size);

    _particles = List.generate(count, (_) {
      final color = colors[_random.nextInt(colors.length)];
      final shape = _randomShape();

      if (widget.kind == CelebrationKind.cracker) {
        return _generateCrackerParticle(
          size: size,
          color: color,
          shape: shape,
          motionScale: motionScale,
        );
      }
      return _generateConfettiParticle(
        size: size,
        color: color,
        shape: shape,
        motionScale: motionScale,
      );
    });
  }

  Particle _generateConfettiParticle({
    required Size size,
    required Color color,
    required ParticleShape shape,
    required double motionScale,
  }) {
    final particleWidth = _randomize(widget.minParticleSize, widget.maxParticleSize) * motionScale;
    final particleHeight =
        _randomize(widget.minParticleSize * 0.7, widget.maxParticleSize * 0.8) * motionScale;

    final horizontalSpread = widget.horizontalSpread ?? c.defaultConfettiHorizontalSpread;
    final startX = _randomize(-size.width * horizontalSpread, size.width * (1 + horizontalSpread));
    final startY = _randomize(-size.height * 0.25, -size.height * 0.05);

    final velocityX = _randomize(-2, 2) * motionScale;
    final velocityY = _randomize(0.6, 2.2) * motionScale;

    return Particle(
      x: startX,
      y: startY,
      velocityX: velocityX,
      velocityY: velocityY,
      color: color,
      width: particleWidth,
      height: particleHeight,
      mass: _randomize(c.minConfettiMass, c.maxConfettiMass),
      angleX: _randomize(0, math.pi * 2),
      angleY: _randomize(0, math.pi * 2),
      angleZ: _randomize(0, math.pi * 2),
      angularVelocityX: _randomize(-0.08, 0.08),
      angularVelocityY: _randomize(-0.08, 0.08),
      angularVelocityZ: _randomize(-0.08, 0.08),
      shape: shape,
      rotateZ: _random.nextBool(),
      swayAmplitude: _randomize(0.6, 2.5) * motionScale,
      swayFrequency: _randomize(0.03, 0.08),
      swayPhase: _randomize(0, math.pi * 2),
      windForce: widget.windForce * motionScale,
    );
  }

  Particle _generateCrackerParticle({
    required Size size,
    required Color color,
    required ParticleShape shape,
    required double motionScale,
  }) {
    final originX = size.width * (widget.originAlignment.x + 1) / 2;
    final originY = size.height * (widget.originAlignment.y + 1) / 2;

    final force = _randomize(widget.minBlastForce, widget.maxBlastForce) * motionScale;
    final angle = (widget.blastDirection ?? -math.pi / 2) + _randomize(-0.7, 0.7);

    final initialVelocityX = math.cos(angle) * force;
    final initialVelocityY = math.sin(angle) * force;

    final crackerWidth = _randomize(c.minCrackerSize, c.maxCrackerSize) * motionScale;
    final crackerHeight = _randomize(4, 10) * motionScale;

    return Particle(
      x: originX,
      y: originY,
      velocityX: initialVelocityX,
      velocityY: initialVelocityY,
      color: color,
      width: crackerWidth,
      height: crackerHeight,
      mass: _randomize(c.minCrackerMass, c.maxCrackerMass),
      angleX: _randomize(0, math.pi * 2),
      angleY: _randomize(0, math.pi * 2),
      angleZ: _randomize(0, math.pi * 2),
      angularVelocityX: _randomize(-0.25, 0.25),
      angularVelocityY: _randomize(-0.25, 0.25),
      angularVelocityZ: _randomize(-0.25, 0.25),
      shape: shape,
      initialBoostX: initialVelocityX * 0.3,
      initialBoostY: initialVelocityY * 0.3 - 2 * motionScale,
      boostFrames: _random.nextInt(8) + 5,
      windForce: widget.windForce * motionScale,
    );
  }

  // ---------------------------------------------------------------------------
  // ビルド
  // ---------------------------------------------------------------------------

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
              painter: CelebrationPainter(
                particles: _particles,
                progress: _animationController.value,
                fadeOutBegin: widget.fadeOutBegin,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}
