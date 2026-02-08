import 'package:flutter/material.dart';

import 'celebration_controller.dart';
import 'constants.dart' as c;
import 'effect_base.dart';
import 'particle_shape.dart';

/// 紙吹雪演出ウィジェット
///
/// 画面上部から色とりどりの紙吹雪が降り注ぐ演出を提供します。
/// 画面サイズに応じてパーティクル数やサイズが自動スケーリングされるため、
/// さまざまなデバイスで自然な見た目になります。
///
/// ## 基本的な使い方
/// ```dart
/// ConfettiEffect(
///   controller: celebrationController,
/// )
/// ```
///
/// ## カスタマイズ例
/// ```dart
/// ConfettiEffect(
///   controller: controller,
///   gravity: 0.12,
///   shapes: [ParticleShape.star, ParticleShape.circle],
///   colors: [Colors.amber, Colors.orange],
///   windForce: 0.02,
/// )
/// ```
class ConfettiEffect extends StatelessWidget {
  /// 紙吹雪演出を生成
  const ConfettiEffect({
    super.key,
    required this.controller,
    this.numberOfParticles,
    this.gravity = c.defaultConfettiGravity,
    this.particleDrag = c.defaultConfettiDrag,
    this.colors,
    this.originAlignment = Alignment.topCenter,
    this.minParticleSize = c.minConfettiSize,
    this.maxParticleSize = c.maxConfettiSize,
    this.horizontalSpread = c.defaultConfettiHorizontalSpread,
    this.referenceSize = const Size(360, 690),
    this.densityScale = 1,
    this.shapes = const [ParticleShape.rectangle],
    this.fadeOutBegin = c.defaultFadeOutBegin,
    this.windForce = 0,
  });

  /// 演出コントローラー
  final CelebrationController controller;

  /// パーティクル数
  ///
  /// 未指定の場合、描画領域のサイズから自動算出されます。
  /// 明示的に指定する場合、90〜260 の範囲が推奨です。
  final int? numberOfParticles;

  /// 重力の強さ（0.0〜1.0）
  ///
  /// 値が大きいほど紙吹雪が速く落下します。
  /// デフォルトは `0.18`。
  final double gravity;

  /// 空気抵抗の強さ（0.0〜1.0）
  ///
  /// 値が大きいほどパーティクルの減速が早くなります。
  /// デフォルトは `0.05`。
  final double particleDrag;

  /// パーティクルの色リスト
  ///
  /// 未指定の場合、赤・青・緑・黄・ピンク・オレンジ・紫・シアンの
  /// 8色からランダムに選ばれます。
  final List<Color>? colors;

  /// パーティクルの発生基準位置
  ///
  /// デフォルトは [Alignment.topCenter]（画面上部中央）。
  final Alignment originAlignment;

  /// パーティクルの最小サイズ（px）
  final double minParticleSize;

  /// パーティクルの最大サイズ（px）
  final double maxParticleSize;

  /// 画面幅に対する生成範囲の拡張率
  ///
  /// `0.12` の場合、画面幅の左右 12% 分だけ生成範囲が広がります。
  /// 値を大きくすると画面端からも紙吹雪が降ってきます。
  final double horizontalSpread;

  /// 自動スケーリングの基準サイズ
  ///
  /// この基準サイズに対する実際の描画サイズの比率で、
  /// パーティクル数や運動量が自動調整されます。
  final Size referenceSize;

  /// パーティクル密度の倍率
  ///
  /// `1.0` が標準密度。`0.5` で半分、`2.0` で2倍。
  /// 内部で 0.5〜2.5 にクランプされます。
  final double densityScale;

  /// パーティクルの形状リスト
  ///
  /// 複数指定すると各パーティクルにランダムで割り当てられ、
  /// バリエーション豊かな演出になります。
  /// デフォルトは `[ParticleShape.rectangle]`。
  final List<ParticleShape> shapes;

  /// フェードアウト開始位置（0.0〜1.0）
  ///
  /// 演出時間の何割目からフェードアウトを開始するか。
  /// デフォルトは `0.7`（70% 経過後にフェードアウト開始）。
  /// `1.0` にするとフェードアウトなし（即座に消える）。
  final double fadeOutBegin;

  /// 風の強さ
  ///
  /// パーティクルに対する水平方向の力。
  /// 正の値で右方向、負の値で左方向に流れます。
  /// `0` で風なし（デフォルト）。`0.01`〜`0.05` 程度が自然な値です。
  final double windForce;

  @override
  Widget build(BuildContext context) {
    return CelebrationEffectWidget(
      controller: controller,
      kind: CelebrationKind.confetti,
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
      shapes: shapes,
      fadeOutBegin: fadeOutBegin,
      windForce: windForce,
    );
  }
}
