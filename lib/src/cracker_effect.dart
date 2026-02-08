import 'package:flutter/material.dart';

import 'celebration_controller.dart';
import 'constants.dart' as c;
import 'effect_base.dart';
import 'particle_shape.dart';

/// クラッカー演出ウィジェット
///
/// 指定した位置からパーティクルが発射されるクラッカー（パーティーポッパー）
/// 演出を提供します。発射方向・力・位置をカスタマイズでき、
/// 画面サイズに応じて自動スケーリングされます。
///
/// ## 基本的な使い方（左下から右上方向に発射）
/// ```dart
/// CrackerEffect(
///   controller: crackerController,
///   blastDirection: -math.pi / 3,
///   originAlignment: const Alignment(-0.95, 0.85),
/// )
/// ```
///
/// ## 左右同時発射
/// ```dart
/// // 左クラッカー
/// CrackerEffect(
///   controller: controller,
///   blastDirection: -math.pi / 3,
///   originAlignment: const Alignment(-0.95, 0.85),
/// ),
/// // 右クラッカー
/// CrackerEffect(
///   controller: controller,
///   blastDirection: -2 * math.pi / 3,
///   originAlignment: const Alignment(0.95, 0.85),
/// ),
/// ```
class CrackerEffect extends StatelessWidget {
  /// クラッカー演出を生成
  const CrackerEffect({
    super.key,
    required this.controller,
    this.blastDirection,
    this.numberOfParticles,
    this.gravity = c.defaultCrackerGravity,
    this.particleDrag = c.defaultCrackerDrag,
    this.maxBlastForce = c.defaultMaxBlastForce,
    this.minBlastForce = c.defaultMinBlastForce,
    this.colors,
    this.originAlignment = Alignment.centerLeft,
    this.minParticleSize = c.minCrackerSize,
    this.maxParticleSize = c.maxCrackerSize,
    this.referenceSize = const Size(360, 690),
    this.densityScale = 1,
    this.shapes = const [ParticleShape.rectangle],
    this.fadeOutBegin = c.defaultFadeOutBegin,
    this.windForce = 0,
  });

  /// 演出コントローラー
  final CelebrationController controller;

  /// クラッカーの発射方向（ラジアン）
  ///
  /// 未指定の場合は真上（$-\pi/2$）に発射されます。
  /// よく使う角度の目安：
  /// - 真上: `-math.pi / 2`
  /// - 右上: `-math.pi / 3`
  /// - 左上: `-2 * math.pi / 3`
  final double? blastDirection;

  /// パーティクル数
  ///
  /// 未指定の場合、描画領域のサイズから自動算出されます。
  /// 明示的に指定する場合、40〜140 の範囲が推奨です。
  final int? numberOfParticles;

  /// 重力の強さ（0.0〜1.0）
  ///
  /// 値が大きいほど発射後の落下が速くなります。
  /// デフォルトは `0.16`。
  final double gravity;

  /// 空気抵抗の強さ（0.0〜1.0）
  ///
  /// デフォルトは `0.03`。
  final double particleDrag;

  /// 最大発射力
  ///
  /// デフォルトは `32`。
  final double maxBlastForce;

  /// 最小発射力
  ///
  /// デフォルトは `14`。
  final double minBlastForce;

  /// パーティクルの色リスト
  ///
  /// 未指定の場合はデフォルトの8色。
  final List<Color>? colors;

  /// パーティクルの発射位置
  ///
  /// デフォルトは [Alignment.centerLeft]（左端中央）。
  final Alignment originAlignment;

  /// パーティクルの最小サイズ（px）
  final double minParticleSize;

  /// パーティクルの最大サイズ（px）
  final double maxParticleSize;

  /// 自動スケーリングの基準サイズ
  final Size referenceSize;

  /// パーティクル密度の倍率
  final double densityScale;

  /// パーティクルの形状リスト
  ///
  /// 複数指定すると各パーティクルにランダムで割り当てられます。
  final List<ParticleShape> shapes;

  /// フェードアウト開始位置（0.0〜1.0）
  ///
  /// デフォルトは `0.7`。
  final double fadeOutBegin;

  /// 風の強さ
  ///
  /// 正の値で右方向、負の値で左方向。
  final double windForce;

  @override
  Widget build(BuildContext context) {
    return CelebrationEffectWidget(
      controller: controller,
      kind: CelebrationKind.cracker,
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
      shapes: shapes,
      fadeOutBegin: fadeOutBegin,
      windForce: windForce,
    );
  }
}
