import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'celebration_controller.dart';

/// スターバースト（星彩）演出ウィジェット
///
/// 画面中央から黄金色の光芒が放射状に回転しながら広がり、
/// 星形のスパークルが螺旋軌道を描いて外側へ飛び出す演出。
/// ゲームの「レベルアップ」や「レア獲得」のような高揚感を表現します。
///
/// 紙吹雪や花火とは異なる、中心から放射する回転光条 + 螺旋パーティクルで
/// 独自の視覚体験を提供します。
///
/// ```dart
/// StarburstEffect(
///   controller: controller,
///   rayCount: 12,
///   sparkleCount: 40,
/// )
/// ```
class StarburstEffect extends StatefulWidget {
  /// スターバースト演出ウィジェットを生成
  const StarburstEffect({
    super.key,
    required this.controller,
    this.rayCount = 12,
    this.sparkleCount = 40,
    this.colors = const [
      Color(0xFFFFD700), // ゴールド
      Color(0xFFFFC107), // アンバー
      Color(0xFFFFFFFF), // ホワイト
      Color(0xFFFF6F00), // ディープアンバー
      Color(0xFFFFF176), // ライトイエロー
    ],
  });

  /// 演出の再生・停止を制御するコントローラー
  final CelebrationController controller;

  /// 放射光条の本数（デフォルト: 12）
  final int rayCount;

  /// 螺旋スパークルの数（デフォルト: 40）
  final int sparkleCount;

  /// 演出の色リスト
  final List<Color> colors;

  @override
  State<StarburstEffect> createState() => _StarburstEffectState();
}

class _StarburstEffectState extends State<StarburstEffect> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<_Sparkle> _sparkles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.controller.duration)
      ..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant StarburstEffect oldWidget) {
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
      widget.controller.notifyComplete();
    }
  }

  void _startAnimation() {
    _animationController.duration = widget.controller.duration;
    _generateSparkles();
    _animationController.forward(from: 0);
  }

  void _stopAnimation() {
    _animationController.stop();
    setState(() => _sparkles = []);
  }

  void _generateSparkles() {
    _sparkles = List.generate(widget.sparkleCount, (i) {
      final angle = (i / widget.sparkleCount) * math.pi * 2 + _random.nextDouble() * 0.3;
      return _Sparkle(
        baseAngle: angle,
        speed: 0.5 + _random.nextDouble() * 0.6,
        spiralTightness: 3.0 + _random.nextDouble() * 4.0,
        startTime: _random.nextDouble() * 0.3,
        size: 2.0 + _random.nextDouble() * 3.0,
        color: widget.colors[_random.nextInt(widget.colors.length)],
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

        return IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) => CustomPaint(
                painter: _StarburstPainter(
                  progress: _animationController.value,
                  center: size.center(Offset.zero),
                  maxRadius: size.shortestSide * 0.6,
                  rayCount: widget.rayCount,
                  sparkles: _sparkles,
                  colors: widget.colors,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 内部データクラス
// ---------------------------------------------------------------------------

class _Sparkle {
  const _Sparkle({
    required this.baseAngle,
    required this.speed,
    required this.spiralTightness,
    required this.startTime,
    required this.size,
    required this.color,
  });

  /// 螺旋の開始角度
  final double baseAngle;

  /// 外側への移動速度（0〜1の比率）
  final double speed;

  /// 螺旋の巻き数
  final double spiralTightness;

  /// 出現開始タイミング（progress比率 0〜0.3）
  final double startTime;

  /// スパークルのサイズ
  final double size;

  /// スパークルの色
  final Color color;
}

// ---------------------------------------------------------------------------
// ペインター
// ---------------------------------------------------------------------------

class _StarburstPainter extends CustomPainter {
  _StarburstPainter({
    required this.progress,
    required this.center,
    required this.maxRadius,
    required this.rayCount,
    required this.sparkles,
    required this.colors,
  });

  final double progress;
  final Offset center;
  final double maxRadius;
  final int rayCount;
  final List<_Sparkle> sparkles;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    // 全体のフェード: フェードイン(0-0.15) → 維持 → フェードアウト(0.75-1.0)
    final globalAlpha = _globalAlpha();
    if (globalAlpha <= 0.01) {
      return;
    }

    // 回転角度（時間とともに回転）
    final rotation = progress * math.pi * 1.5;

    // 光条の拡大率（0→1）
    final expand = Curves.easeOutCubic.transform((progress / 0.5).clamp(0.0, 1.0));

    _drawGlow(canvas, globalAlpha, expand);
    _drawRays(canvas, globalAlpha, expand, rotation);
    _drawSparkles(canvas, globalAlpha);
    _drawCenterFlash(canvas, globalAlpha, expand);
  }

  double _globalAlpha() {
    if (progress < 0.12) {
      return (progress / 0.12).clamp(0.0, 1.0);
    }
    if (progress > 0.75) {
      return ((1.0 - progress) / 0.25).clamp(0.0, 1.0);
    }
    return 1;
  }

  /// 中心からの放射状グロー
  void _drawGlow(Canvas canvas, double alpha, double expand) {
    final glowRadius = maxRadius * expand * 0.8;
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFD700).withValues(alpha: alpha * 0.25),
        const Color(0xFFFFD700).withValues(alpha: alpha * 0.08),
        const Color(0xFFFFD700).withValues(alpha: 0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: glowRadius)),
    );
  }

  /// 放射光条を描画
  void _drawRays(Canvas canvas, double alpha, double expand, double rotation) {
    final rayLength = maxRadius * expand;
    // 脈動
    final pulse = 0.8 + 0.2 * math.sin(progress * math.pi * 8);

    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (i / rayCount) * math.pi * 2;
      final color = colors[i % colors.length];
      final rayOpacity = alpha * 0.45 * pulse;

      // 光条は先端に向かって細くなる三角形
      final halfWidth = 3.0 + (i.isEven ? 1.5 : 0);
      final endX = center.dx + math.cos(angle) * rayLength;
      final endY = center.dy + math.sin(angle) * rayLength;

      final perpX = -math.sin(angle) * halfWidth;
      final perpY = math.cos(angle) * halfWidth;

      final path = Path()
        ..moveTo(center.dx + perpX, center.dy + perpY)
        ..lineTo(endX, endY)
        ..lineTo(center.dx - perpX, center.dy - perpY)
        ..close();

      final shader = LinearGradient(
        colors: [
          color.withValues(alpha: rayOpacity),
          color.withValues(alpha: rayOpacity * 0.3),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromPoints(center, Offset(endX, endY)).inflate(halfWidth));

      canvas.drawPath(path, Paint()..shader = shader);
    }
  }

  /// 螺旋軌道のスパークルを描画
  void _drawSparkles(Canvas canvas, double alpha) {
    for (final s in sparkles) {
      // まだ出現前ならスキップ
      if (progress < s.startTime) {
        continue;
      }

      final localProgress = ((progress - s.startTime) / (1.0 - s.startTime)).clamp(0.0, 1.0);
      final t = Curves.easeOut.transform(localProgress);

      // 螺旋: 外側へ移動しながら角度が増加
      final radius = t * maxRadius * s.speed;
      final angle = s.baseAngle + t * s.spiralTightness * math.pi * 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      // フェードアウト
      final sparkleAlpha = alpha * (1.0 - t * t);
      if (sparkleAlpha <= 0.01) {
        continue;
      }

      final pos = Offset(x, y);

      // 4方向のスパイクで星形を表現
      _drawStarSparkle(canvas, pos, s.size * (1.0 + t * 0.5), s.color, sparkleAlpha);
    }
  }

  /// 小さな星形スパークル（十字＋斜め十字）
  void _drawStarSparkle(Canvas canvas, Offset pos, double size, Color color, double alpha) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.8)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // 十字
    canvas
      ..drawLine(Offset(pos.dx - size, pos.dy), Offset(pos.dx + size, pos.dy), paint)
      ..drawLine(Offset(pos.dx, pos.dy - size), Offset(pos.dx, pos.dy + size), paint);

    // 斜め十字（短め）
    final diagSize = size * 0.6;
    final diagPaint = Paint()
      ..color = color.withValues(alpha: alpha * 0.5)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(pos.dx - diagSize, pos.dy - diagSize),
        Offset(pos.dx + diagSize, pos.dy + diagSize),
        diagPaint,
      )
      ..drawLine(
        Offset(pos.dx + diagSize, pos.dy - diagSize),
        Offset(pos.dx - diagSize, pos.dy + diagSize),
        diagPaint,
      )
      // 中心の明るいドット
      ..drawCircle(
        pos,
        size * 0.3,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.9),
      );
  }

  /// 中心のフラッシュ（開始直後の閃光）
  void _drawCenterFlash(Canvas canvas, double alpha, double expand) {
    // 最初の20%だけフラッシュ
    if (progress > 0.20) {
      return;
    }
    final flashAlpha = alpha * (1.0 - progress / 0.20);

    canvas
      ..drawCircle(
        center,
        24 * (1.0 + expand * 0.5),
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: flashAlpha * 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + expand * 10),
      )
      ..drawCircle(
        center,
        8,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: flashAlpha),
      );
  }

  @override
  bool shouldRepaint(covariant _StarburstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
