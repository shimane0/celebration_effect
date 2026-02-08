import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'celebration_controller.dart';

/// リップル（波紋）演出ウィジェット
///
/// 画面中央から光の輪が同心円状に時間差で次々と広がっていく演出。
/// 水面に石を落とした波紋のように、複数の色の輪が重なりながら
/// 外側へ拡散しフェードアウトします。
///
/// 他のエフェクト（紙吹雪・花火・スポットライト）とは完全に異なる
/// 静謐かつ幻想的な質感を提供します。
///
/// ```dart
/// RippleEffect(
///   controller: controller,
///   ringCount: 6,
/// )
/// ```
class RippleEffect extends StatefulWidget {
  /// リップル演出ウィジェットを生成
  const RippleEffect({
    super.key,
    required this.controller,
    this.ringCount = 6,
    this.colors = const [
      Color(0xFF80DEEA), // ライトシアン
      Color(0xFFB388FF), // ライトパープル
      Color(0xFF82B1FF), // ライトブルー
      Color(0xFF80CBC4), // ライトティール
      Color(0xFFFFFFFF), // 白
      Color(0xFFCE93D8), // ライトラベンダー
    ],
    this.maxRingOpacity = 0.60,
    this.ringWidth = 3.0,
  });

  /// 演出の再生・停止を制御するコントローラー
  final CelebrationController controller;

  /// 波紋リングの本数（デフォルト: 6）
  final int ringCount;

  /// 色リスト
  ///
  /// 各リングに順番に割り当てられます。
  final List<Color> colors;

  /// リングの最大不透明度（0.0〜1.0）
  final double maxRingOpacity;

  /// リングの太さ（ピクセル）
  final double ringWidth;

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.controller.duration)
      ..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RippleEffect oldWidget) {
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
    _animationController
      ..duration = widget.controller.duration
      ..forward(from: 0);
  }

  void _stopAnimation() {
    _animationController.stop();
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
                painter: _RipplePainter(
                  progress: _animationController.value,
                  center: size.center(Offset.zero),
                  maxRadius: math.sqrt(size.width * size.width + size.height * size.height) / 2,
                  ringCount: widget.ringCount,
                  colors: widget.colors,
                  maxOpacity: widget.maxRingOpacity,
                  ringWidth: widget.ringWidth,
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
// ペインター
// ---------------------------------------------------------------------------

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.progress,
    required this.center,
    required this.maxRadius,
    required this.ringCount,
    required this.colors,
    required this.maxOpacity,
    required this.ringWidth,
  });

  final double progress;
  final Offset center;
  final double maxRadius;
  final int ringCount;
  final List<Color> colors;
  final double maxOpacity;
  final double ringWidth;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCenterGlow(canvas);

    for (var i = 0; i < ringCount; i++) {
      _drawRing(canvas, i);
    }
  }

  /// 中心からの放射状グロー（初期フラッシュ）
  void _drawCenterGlow(Canvas canvas) {
    // 最初の30%でフラッシュ → フェードアウト
    if (progress > 0.35) {
      return;
    }
    final t = (progress / 0.35).clamp(0.0, 1.0);
    final flashAlpha = (1.0 - t * t) * 0.40;
    final glowRadius = 30.0 + t * maxRadius * 0.15;

    final gradient = RadialGradient(
      colors: [
        const Color(0xFFFFFFFF).withValues(alpha: flashAlpha),
        colors.first.withValues(alpha: flashAlpha * 0.5),
        colors.first.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    canvas.drawCircle(
      center,
      glowRadius,
      Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: glowRadius)),
    );
  }

  /// 個々のリングを描画
  void _drawRing(Canvas canvas, int index) {
    // 各リングは時間差で発射（0.0, 0.08, 0.16, ...）
    final delay = index * (0.45 / math.max(ringCount - 1, 1));
    if (progress < delay) {
      return;
    }

    // リングローカルの進行度（0→1）
    final localProgress = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final t = Curves.easeOutCubic.transform(localProgress);

    // 半径の拡大
    final radius = t * maxRadius;

    // 不透明度: 出現 → 維持 → フェードアウト
    double alpha;
    if (localProgress < 0.15) {
      alpha = localProgress / 0.15;
    } else {
      alpha = (1.0 - localProgress) / 0.85;
    }
    alpha = alpha * maxOpacity;
    alpha = alpha.clamp(0.0, 1.0);
    if (alpha <= 0.01) {
      return;
    }

    final color = colors[index % colors.length];

    // グローリング（太くぼかした外側）
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * 6
          ..color = color.withValues(alpha: alpha * 0.15)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, ringWidth * 3),
      )
      // メインリング
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * (1.0 + (1.0 - t) * 1.5)
          ..color = color.withValues(alpha: alpha),
      )
      // 内側の明るいエッジ
      ..drawCircle(
        center,
        radius - ringWidth * 0.3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.6),
      );
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
