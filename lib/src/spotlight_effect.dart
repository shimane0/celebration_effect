import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'celebration_controller.dart';

/// スポットライト演出ウィジェット
///
/// 画面下部から複数の光のビームが上方へ照射されるステージ照明風アニメーション。
/// パーティクルベースではなく、グラデーション描画による滑らかな光の筋を表現します。
///
/// 左右のビームは交差するようにファン状に配置され、
/// 各ビームは時間差でフェードインし、ゆるやかにスイープしたのちフェードアウトします。
///
/// ```dart
/// SpotlightEffect(
///   controller: controller,
///   beamCount: 7,
///   colors: [Colors.white, Color(0xFFFFD700), Color(0xFF00E5FF)],
/// )
/// ```
class SpotlightEffect extends StatefulWidget {
  /// スポットライト演出ウィジェットを生成
  const SpotlightEffect({
    super.key,
    required this.controller,
    this.beamCount = 7,
    this.colors = const [
      Color(0xFFFFFFFF), // 白
      Color(0xFFFFD700), // ゴールド
      Color(0xFF00E5FF), // シアン
      Color(0xFFFF4081), // ピンク
      Color(0xFF7C4DFF), // パープル
      Color(0xFF64FFDA), // ティール
      Color(0xFFFF6E40), // ディープオレンジ
    ],
    this.maxBeamOpacity = 0.55,
    this.sweepRange = 0.06,
  });

  /// 演出の再生・停止を制御するコントローラー
  final CelebrationController controller;

  /// ビームの本数（デフォルト: 7）
  final int beamCount;

  /// ビームの色リスト
  ///
  /// 各ビームに順番に割り当てられます。
  final List<Color> colors;

  /// ビームの最大不透明度（0.0〜1.0）
  ///
  /// 値が小さいほど控えめな演出になります。
  final double maxBeamOpacity;

  /// ビームの角度スイープ幅（ラジアン）
  ///
  /// 値が大きいほどビームの揺れが大きくなります。
  final double sweepRange;

  @override
  State<SpotlightEffect> createState() => _SpotlightEffectState();
}

class _SpotlightEffectState extends State<SpotlightEffect> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<_BeamConfig> _beams = [];
  final _random = math.Random();
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.controller.duration)
      ..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SpotlightEffect oldWidget) {
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
    if (_canvasSize != null) {
      _generateBeams(_canvasSize!);
    }
    _animationController.forward(from: 0);
  }

  void _stopAnimation() {
    _animationController.stop();
    setState(() => _beams = []);
  }

  void _generateBeams(Size size) {
    _beams = List.generate(widget.beamCount, (i) {
      // ステージ照明: 画面下端から上方向にファン状に照射
      // t: -1.0（左端）〜 1.0（右端）
      final t = widget.beamCount == 1 ? 0.0 : (i / (widget.beamCount - 1)) * 2 - 1;

      // 光源の水平位置（端に寄せる）
      final sourceX = 0.5 + t * 0.45;

      // ビーム角度（左のビームは右上へ、右のビームは左上へ、クロスするファン配置）
      final baseAngle = -t * 0.50;

      final color = widget.colors[i % widget.colors.length];
      return _BeamConfig(
        sourceX: sourceX,
        baseAngle: baseAngle,
        phase: _random.nextDouble() * math.pi * 2,
        sweepSpeed: 0.8 + _random.nextDouble() * 1.2,
        pulseSpeed: 2.5 + _random.nextDouble() * 2.0,
        sourceWidth: 4 + _random.nextDouble() * 4,
        spreadFraction: 0.10 + _random.nextDouble() * 0.08,
        lengthFraction: 0.70 + _random.nextDouble() * 0.25,
        color: color,
        fadeInStart: i * 0.04,
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
          if (widget.controller.isPlaying && _beams.isEmpty) {
            _generateBeams(size);
          }
        }

        if (_beams.isEmpty) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) => CustomPaint(
                painter: _SpotlightPainter(
                  beams: _beams,
                  progress: _animationController.value,
                  maxOpacity: widget.maxBeamOpacity,
                  sweepRange: widget.sweepRange,
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

class _BeamConfig {
  const _BeamConfig({
    required this.sourceX,
    required this.baseAngle,
    required this.phase,
    required this.sweepSpeed,
    required this.pulseSpeed,
    required this.sourceWidth,
    required this.spreadFraction,
    required this.lengthFraction,
    required this.color,
    required this.fadeInStart,
  });

  /// 光源の水平位置（0〜1、画面幅の比率）
  final double sourceX;

  /// ビームのベース角度（ラジアン、0=真上、正=右、負=左）
  final double baseAngle;

  /// サイン波の初期位相
  final double phase;

  /// スイープ速度（サイクル数/アニメーション全体）
  final double sweepSpeed;

  /// 脈動速度（サイクル数/アニメーション全体）
  final double pulseSpeed;

  /// 光源での幅（ピクセル）
  final double sourceWidth;

  /// 終端での広がり幅（画面幅に対する比率）
  final double spreadFraction;

  /// ビームの長さ（画面高さに対する比率）
  final double lengthFraction;

  /// ビームの色
  final Color color;

  /// フェードイン開始タイミング（0〜1）
  final double fadeInStart;
}

// ---------------------------------------------------------------------------
// ペインター
// ---------------------------------------------------------------------------

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.beams,
    required this.progress,
    required this.maxOpacity,
    required this.sweepRange,
  });

  final List<_BeamConfig> beams;
  final double progress;
  final double maxOpacity;
  final double sweepRange;

  @override
  void paint(Canvas canvas, Size size) {
    for (final beam in beams) {
      _drawBeam(canvas, size, beam);
    }
  }

  void _drawBeam(Canvas canvas, Size size, _BeamConfig beam) {
    // フェードイン → 維持 → フェードアウト
    final fadeInEnd = (beam.fadeInStart + 0.15).clamp(0.0, 1.0);
    double opacity;
    if (progress < beam.fadeInStart) {
      opacity = 0;
    } else if (progress < fadeInEnd) {
      final t = (progress - beam.fadeInStart) / (fadeInEnd - beam.fadeInStart);
      opacity = t * t; // ease-in
    } else if (progress < 0.75) {
      opacity = 1.0;
    } else {
      final t = (1.0 - progress) / 0.25;
      opacity = t * t; // ease-out
    }

    // 脈動（微かな明滅）
    final pulse = 0.85 + 0.15 * math.sin(progress * beam.pulseSpeed * math.pi * 2 + beam.phase);
    opacity *= pulse * maxOpacity;
    opacity = opacity.clamp(0.0, 1.0);

    if (opacity <= 0.01) {
      return;
    }

    // スイープ（ベース角度からの微小な角度揺れ）
    final sweepAngle = math.sin(beam.phase + progress * beam.sweepSpeed * math.pi * 2) * sweepRange;
    final angle = beam.baseAngle + sweepAngle;

    // 光源位置（画面下端）
    final sourceX = beam.sourceX * size.width;
    final sourceY = size.height;

    // ビーム方向ベクトル
    final sinA = math.sin(angle);
    final cosA = math.cos(angle);
    final beamLength = beam.lengthFraction * size.height;

    // 終端位置
    final endX = sourceX + beamLength * sinA;
    final endY = sourceY - beamLength * cosA;

    // ビーム軸に直交する方向
    final perpX = cosA;
    final perpY = sinA;

    final sourceHW = beam.sourceWidth / 2;
    final endHW = beam.spreadFraction * size.width / 2;

    // グロー（広く半透明のビーム）
    _drawBeamShape(
      canvas: canvas,
      sourceX: sourceX,
      sourceY: sourceY,
      endX: endX,
      endY: endY,
      sourceHW: sourceHW * 3,
      endHW: endHW * 1.8,
      perpX: perpX,
      perpY: perpY,
      color: beam.color,
      opacity: opacity * 0.2,
    );

    // コアビーム
    _drawBeamShape(
      canvas: canvas,
      sourceX: sourceX,
      sourceY: sourceY,
      endX: endX,
      endY: endY,
      sourceHW: sourceHW,
      endHW: endHW,
      perpX: perpX,
      perpY: perpY,
      color: beam.color,
      opacity: opacity,
    );

    // 光源グロー（下端の明るいスポット）
    canvas.drawCircle(
      Offset(sourceX, sourceY),
      14,
      Paint()
        ..color = beam.color.withValues(alpha: opacity * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
  }

  void _drawBeamShape({
    required Canvas canvas,
    required double sourceX,
    required double sourceY,
    required double endX,
    required double endY,
    required double sourceHW,
    required double endHW,
    required double perpX,
    required double perpY,
    required Color color,
    required double opacity,
  }) {
    // 台形パス（光源:狭い → 終端:広い）
    final path = Path()
      ..moveTo(sourceX - sourceHW * perpX, sourceY - sourceHW * perpY)
      ..lineTo(endX - endHW * perpX, endY - endHW * perpY)
      ..lineTo(endX + endHW * perpX, endY + endHW * perpY)
      ..lineTo(sourceX + sourceHW * perpX, sourceY + sourceHW * perpY)
      ..close();

    // ビーム軸方向のグラデーション（光源で明るく、先端で消える）
    final rect = Rect.fromPoints(Offset(sourceX, sourceY), Offset(endX, endY)).inflate(endHW);

    final shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        color.withValues(alpha: opacity),
        color.withValues(alpha: opacity * 0.5),
        color.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(rect);

    canvas.drawPath(path, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
