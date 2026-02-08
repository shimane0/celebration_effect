import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'celebration_controller.dart';
import 'confetti_effect.dart';
import 'cracker_effect.dart';
import 'particle_shape.dart';

/// 定義済みの祝福演出プリセット
///
/// よく使われる演出パターンを簡単に適用できるファクトリメソッドを提供します。
/// 各プリセットは `List<Widget>` を返すため、
/// `CelebrationOverlay` の `effects` にそのまま渡せます。
///
/// ```dart
/// CelebrationOverlay(
///   child: MyContent(),
///   effects: CelebrationPreset.birthday(controller: controller),
/// )
/// ```
///
/// ## 利用可能なプリセット
///
/// | プリセット | 説明 |
/// |---|---|
/// | [birthday] | カラフルな紙吹雪＋左右クラッカーの華やかな構成 |
/// | [achievement] | ゴールド＆シルバー系の上品な紙吹雪 |
/// | [gentle] | 少量の小さな紙吹雪が静かに舞い降りる控えめな演出 |
/// | [intense] | 大量パーティクル＋左右クラッカーの全部盛り |
/// | [sakura] | ピンク系の淡い色合いでゆったりと舞い落ちる桜吹雪風 |
final class CelebrationPreset {
  CelebrationPreset._();

  /// 誕生日・お祝い向け演出
  ///
  /// カラフルな紙吹雪と左右のクラッカーの華やかな構成。
  /// パーティー・記念日など華やかなシーンに最適です。
  static List<Widget> birthday({required CelebrationController controller}) {
    return [
      ConfettiEffect(
        controller: controller,
        shapes: const [ParticleShape.rectangle, ParticleShape.circle, ParticleShape.star],
      ),
      CrackerEffect(
        controller: controller,
        blastDirection: -math.pi / 3,
        originAlignment: const Alignment(-0.95, 0.85),
        maxBlastForce: 35,
        minBlastForce: 18,
        shapes: const [ParticleShape.rectangle, ParticleShape.star],
      ),
      CrackerEffect(
        controller: controller,
        blastDirection: -2 * math.pi / 3,
        originAlignment: const Alignment(0.95, 0.85),
        maxBlastForce: 35,
        minBlastForce: 18,
        shapes: const [ParticleShape.rectangle, ParticleShape.star],
      ),
    ];
  }

  /// 達成・アチーブメント向け演出
  ///
  /// ゴールド＆シルバー系の上品な紙吹雪。
  /// ミッション達成・レベルアップなどの報酬演出に適しています。
  static List<Widget> achievement({required CelebrationController controller}) {
    return [
      ConfettiEffect(
        controller: controller,
        colors: const [
          Color(0xFFFFD700), // ゴールド
          Color(0xFFFFC107), // アンバー
          Color(0xFFC0C0C0), // シルバー
          Color(0xFFE0E0E0), // ライトシルバー
          Color(0xFFFFE082), // ライトゴールド
        ],
        shapes: const [ParticleShape.star, ParticleShape.rectangle, ParticleShape.circle],
        gravity: 0.12,
        densityScale: 0.8,
      ),
    ];
  }

  /// 控えめ・さりげない演出
  ///
  /// 少量の小さな紙吹雪が静かに舞い降りる演出。
  /// 日常的な小さな成功やタスク完了の通知に適しています。
  static List<Widget> gentle({required CelebrationController controller}) {
    return [
      ConfettiEffect(
        controller: controller,
        numberOfParticles: 40,
        gravity: 0.08,
        particleDrag: 0.07,
        minParticleSize: 4,
        maxParticleSize: 10,
        shapes: const [ParticleShape.circle, ParticleShape.rectangle],
      ),
    ];
  }

  /// 激しい・派手な演出
  ///
  /// 大量のパーティクル＋左右クラッカー＋風の全部盛り。
  /// 大きな節目やクライマックスの演出に。
  static List<Widget> intense({required CelebrationController controller}) {
    return [
      ConfettiEffect(
        controller: controller,
        densityScale: 2,
        shapes: const [
          ParticleShape.rectangle,
          ParticleShape.circle,
          ParticleShape.triangle,
          ParticleShape.star,
          ParticleShape.streamer,
        ],
        windForce: 0.015,
      ),
      CrackerEffect(
        controller: controller,
        blastDirection: -math.pi / 3,
        originAlignment: const Alignment(-0.95, 0.85),
        maxBlastForce: 40,
        minBlastForce: 22,
        densityScale: 1.5,
        shapes: const [ParticleShape.rectangle, ParticleShape.star, ParticleShape.streamer],
      ),
      CrackerEffect(
        controller: controller,
        blastDirection: -2 * math.pi / 3,
        originAlignment: const Alignment(0.95, 0.85),
        maxBlastForce: 40,
        minBlastForce: 22,
        densityScale: 1.5,
        shapes: const [ParticleShape.rectangle, ParticleShape.star, ParticleShape.streamer],
      ),
    ];
  }

  /// 桜吹雪風演出
  ///
  /// ピンク系の淡い色合いで、右方向の風に乗ってゆったりと舞い落ちる演出。
  /// 春のイベントや和風テーマに。
  static List<Widget> sakura({required CelebrationController controller}) {
    return [
      ConfettiEffect(
        controller: controller,
        colors: const [
          Color(0xFFFFB7C5), // さくら色
          Color(0xFFF8BBD0), // ライトピンク
          Color(0xFFFCE4EC), // ペールピンク
          Color(0xFFF48FB1), // ピンク
          Color(0xFFFFFFFF), // 白
        ],
        gravity: 0.06,
        particleDrag: 0.06,
        shapes: const [ParticleShape.circle, ParticleShape.streamer],
        windForce: 0.025,
        densityScale: 0.7,
        fadeOutBegin: 0.8,
      ),
    ];
  }
}
