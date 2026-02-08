import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'celebration_controller.dart';

/// 花火演出ウィジェット
///
/// 画面上部の複数地点から時間差で花火が打ち上がり、放射状に爆発する演出。
/// 各花火（シェル）は球状にパーティクルを放出し、重力で弧を描いて落下します。
/// パーティクルは光の尾を引き、フラッシュと共に爆発する花火を再現します。
///
/// 既存の紙吹雪・クラッカーとは独立した専用の物理シミュレーションで動作します。
///
/// ```dart
/// FireworkEffect(
///   controller: controller,
///   shellCount: 4,
///   particlesPerShell: 70,
/// )
/// ```
class FireworkEffect extends StatefulWidget {
  /// 花火演出ウィジェットを生成
  const FireworkEffect({
    super.key,
    required this.controller,
    this.shellCount = 8,
    this.particlesPerShell = 80,
    this.gravity = 0.12,
    this.drag = 0.018,
    this.trailFactor = 3.0,
  });

  /// 演出の再生・停止を制御するコントローラー
  final CelebrationController controller;

  /// 花火（シェル）の数（デフォルト: 8）
  ///
  /// 各シェルは異なる位置・タイミングで爆発します。
  final int shellCount;

  /// シェルあたりのパーティクル数（デフォルト: 70）
  final int particlesPerShell;

  /// 重力の強さ（ピクセル/フレーム²）
  ///
  /// 値が大きいほどパーティクルが早く落下します。
  final double gravity;

  /// 空気抵抗（0.0〜1.0）
  ///
  /// 各フレームで速度にかかる減衰率。値が大きいほど早く減速します。
  final double drag;

  /// 尾の長さ倍率
  ///
  /// パーティクルの速度ベクトルに対する尾の描画倍率。
  final double trailFactor;

  @override
  State<FireworkEffect> createState() => _FireworkEffectState();
}

class _FireworkEffectState extends State<FireworkEffect> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<_FireworkShell> _shells = [];
  final _random = math.Random();
  Size? _canvasSize;

  /// シェルごとの色テーマ
  static const _colorThemes = [
    [Color(0xFFFF1744), Color(0xFFFF5252), Color(0xFFFF8A80), Color(0xFFFFFFFF)],
    [Color(0xFF00E5FF), Color(0xFF18FFFF), Color(0xFF84FFFF), Color(0xFFFFFFFF)],
    [Color(0xFFFFD700), Color(0xFFFFC107), Color(0xFFFFE082), Color(0xFFFFFFFF)],
    [Color(0xFFE040FB), Color(0xFFEA80FC), Color(0xFFF8BBD0), Color(0xFFFFFFFF)],
    [Color(0xFF76FF03), Color(0xFFB2FF59), Color(0xFFCCFF90), Color(0xFFFFFFFF)],
    [Color(0xFF448AFF), Color(0xFF82B1FF), Color(0xFFBBDEFB), Color(0xFFFFFFFF)],
    [Color(0xFFFF9100), Color(0xFFFFAB40), Color(0xFFFFD180), Color(0xFFFFFFFF)],
    [Color(0xFFFFFFFF), Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFFFF9C4)],
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.controller.duration)
      ..addListener(_onTick)
      ..addStatusListener(_onAnimationStatus);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FireworkEffect oldWidget) {
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
      _generateShells(_canvasSize!);
    }
    _animationController.forward(from: 0);
  }

  void _stopAnimation() {
    _animationController.stop();
    setState(() => _shells = []);
  }

  // ---------------------------------------------------------------------------
  // シェル・パーティクル生成
  // ---------------------------------------------------------------------------

  void _generateShells(Size size) {
    final motionScale = (size.shortestSide / 400).clamp(0.8, 1.5);

    _shells = List.generate(widget.shellCount, (i) {
      // 各シェルの爆発タイミング（0.0〜0.55 にステージング）
      final burstTime = i * (0.55 / math.max(widget.shellCount - 1, 1));

      // 爆発位置: 画面上部10-45%の高さ、横は15-85%
      final centerX = size.width * (0.15 + _random.nextDouble() * 0.7);
      final centerY = size.height * (0.10 + _random.nextDouble() * 0.35);

      final colors = _colorThemes[i % _colorThemes.length];

      return _FireworkShell(
        center: Offset(centerX, centerY),
        burstTime: burstTime,
        particles: _generateParticles(colors, motionScale),
      );
    });
  }

  List<_FireworkParticle> _generateParticles(List<Color> colors, double motionScale) {
    return List.generate(widget.particlesPerShell, (i) {
      // 360度均等に分散 + わずかなランダムずれ
      final angle = (i / widget.particlesPerShell) * math.pi * 2 + _random.nextDouble() * 0.3;
      // 速度にバリエーション（内側と外側のパーティクルを作る）
      final speed = (6 + _random.nextDouble() * 10) * motionScale;
      final color = colors[_random.nextInt(colors.length)];
      final particleSize = (1.5 + _random.nextDouble() * 2.0) * motionScale;

      return _FireworkParticle(
        angle: angle,
        speed: speed,
        color: color,
        size: particleSize,
        // 減衰率にバリエーション（外側は早く消え、内側は長く残る）
        decayRate: 0.010 + _random.nextDouble() * 0.008,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 毎フレーム物理更新
  // ---------------------------------------------------------------------------

  void _onTick() {
    final progress = _animationController.value;

    setState(() {
      for (final shell in _shells) {
        // まだ爆発前のシェルはスキップ
        if (progress < shell.burstTime) {
          continue;
        }

        // 初回起動: パーティクルの初期速度を設定
        if (!shell.activated) {
          _activateShell(shell);
        }

        // パーティクル物理更新
        _updateShellParticles(shell);

        // 爆発フラッシュの減衰
        shell.flashLife = math.max(0, shell.flashLife - 0.06);
      }
    });
  }

  void _activateShell(_FireworkShell shell) {
    for (final p in shell.particles) {
      p
        ..x = shell.center.dx
        ..y = shell.center.dy
        ..prevX = shell.center.dx
        ..prevY = shell.center.dy
        ..vx = math.cos(p.angle) * p.speed
        ..vy = math.sin(p.angle) * p.speed;
    }
    shell.activated = true;
  }

  void _updateShellParticles(_FireworkShell shell) {
    final gravity = widget.gravity;
    final dragFactor = 1 - widget.drag;
    final screenW = _canvasSize?.width ?? 500;
    final screenH = _canvasSize?.height ?? 800;

    for (final p in shell.particles) {
      if (p.life <= 0) {
        continue;
      }

      // 前フレーム位置を保存・物理演算・ライフ減衰を一括適用
      p
        ..prevX = p.x
        ..prevY = p.y
        ..vy += gravity
        ..vx *= dragFactor
        ..vy *= dragFactor
        ..x += p.vx
        ..y += p.vy
        ..life -= p.decayRate;

      // 画面外に出たパーティクルは早期終了
      if (p.x < -50 || p.x > screenW + 50 || p.y > screenH + 50) {
        p.life = 0;
      }
    }
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
          if (widget.controller.isPlaying && _shells.isEmpty) {
            _generateShells(size);
          }
        }

        if (_shells.isEmpty) {
          return const SizedBox.shrink();
        }

        return IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _FireworkPainter(shells: _shells, trailFactor: widget.trailFactor),
              size: Size.infinite,
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

/// 花火の一発分（シェル）
class _FireworkShell {
  _FireworkShell({required this.center, required this.burstTime, required this.particles});

  /// 爆発中心座標
  final Offset center;

  /// 爆発タイミング（0〜1、アニメーション全体比率）
  final double burstTime;

  /// このシェルのパーティクル群
  final List<_FireworkParticle> particles;

  /// 起動済みか
  bool activated = false;

  /// 爆発フラッシュの残存ライフ（1.0→0.0に減衰）
  double flashLife = 1;
}

/// 花火パーティクル
class _FireworkParticle {
  _FireworkParticle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.decayRate,
  });

  /// 発射角度（ラジアン）
  final double angle;

  /// 初速（ピクセル/フレーム）
  final double speed;

  /// パーティクルの色
  final Color color;

  /// パーティクルのサイズ
  final double size;

  /// ライフの減衰率（/フレーム）
  final double decayRate;

  /// 現在座標
  double x = 0;
  double y = 0;

  /// 速度
  double vx = 0;
  double vy = 0;

  /// 残存ライフ（1.0→0.0）
  double life = 1;

  /// 前フレームの座標（尾の描画用）
  double prevX = 0;
  double prevY = 0;
}

// ---------------------------------------------------------------------------
// ペインター
// ---------------------------------------------------------------------------

class _FireworkPainter extends CustomPainter {
  _FireworkPainter({required this.shells, required this.trailFactor});

  final List<_FireworkShell> shells;
  final double trailFactor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final shell in shells) {
      if (!shell.activated) {
        continue;
      }

      // 爆発フラッシュ（シェル起動直後の白い閃光）
      if (shell.flashLife > 0) {
        _drawFlash(canvas, shell);
      }

      // パーティクル描画
      for (final p in shell.particles) {
        if (p.life <= 0) {
          continue;
        }
        _drawParticle(canvas, p);
      }
    }
  }

  /// 爆発時のフラッシュを描画
  void _drawFlash(Canvas canvas, _FireworkShell shell) {
    final alpha = shell.flashLife;

    // 大きな白いグロー
    canvas
      ..drawCircle(
        shell.center,
        20 * alpha,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: alpha * 0.7)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * alpha),
      )
      // 明るいコア
      ..drawCircle(
        shell.center,
        8 * alpha,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
      );
  }

  /// パーティクル1個を描画（尾 + グロー + コア）
  void _drawParticle(Canvas canvas, _FireworkParticle p) {
    final alpha = p.life.clamp(0.0, 1.0);
    final pos = Offset(p.x, p.y);

    // 尾（速度方向に延びる線）
    final dx = p.x - p.prevX;
    final dy = p.y - p.prevY;
    final tailEnd = Offset(p.x - dx * trailFactor, p.y - dy * trailFactor);
    canvas
      ..drawLine(
        tailEnd,
        pos,
        Paint()
          ..color = p.color.withValues(alpha: alpha * 0.3)
          ..strokeWidth = p.size * 0.7
          ..strokeCap = StrokeCap.round,
      )
      // グロー（大きく半透明の円）
      ..drawCircle(pos, p.size * 2.5, Paint()..color = p.color.withValues(alpha: alpha * 0.12));

    // コア（白寄りの明るい中心）
    final coreColor = Color.lerp(p.color, const Color(0xFFFFFFFF), 0.35)!;
    canvas.drawCircle(pos, p.size * 0.7, Paint()..color = coreColor.withValues(alpha: alpha));
  }

  @override
  bool shouldRepaint(covariant _FireworkPainter oldDelegate) => true;
}
