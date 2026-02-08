import 'package:flutter/material.dart';

import 'celebration_controller.dart';
import 'confetti_effect.dart';
import 'firework_effect.dart';
import 'particle_shape.dart';
import 'spotlight_effect.dart';

/// 定義済みの祝福演出プリセット
///
/// よく使われる演出パターンを簡単に適用できるファクトリメソッドを提供します。
/// 各プリセットは `List<Widget>` を返すため、
/// `CelebrationOverlay` の `effects` にそのまま渡せます。
///
/// ```dart
/// CelebrationOverlay(
///   child: MyContent(),
///   effects: CelebrationPreset.spotlight(controller: controller),
/// )
/// ```
///
/// ## 利用可能なプリセット
///
/// | プリセット | 説明 |
/// |---|---|
/// | [spotlight] | 画面上部から光のビームが降り注ぐステージ照明風 |
/// | [achievement] | ゴールド＆シルバー系の上品な紙吹雪 |
/// | [gentle] | 少量の小さな紙吹雪が静かに舞い降りる控えめな演出 |
/// | [firework] | 複数シェルが時間差で爆発する本格的な花火 |
/// | [sakura] | ピンク系の淡い色合いでゆったりと舞い落ちる桜吹雪風 |
final class CelebrationPreset {
  CelebrationPreset._();

  /// スポットライト演出
  ///
  /// 画面上部から複数の光のビームが降り注ぐステージ照明風演出。
  /// グラデーション描画による滑らかなビームが左右にスイープし、
  /// 脈動しながらフェードインアウトします。
  /// ライブ・表彰・発表会など華やかなシーンに最適です。
  static List<Widget> spotlight({required CelebrationController controller}) {
    return [SpotlightEffect(controller: controller)];
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

  /// 花火演出
  ///
  /// 画面上部の複数地点から時間差で花火が打ち上がり、
  /// 球状に爆発するパーティクルが重力で弧を描いて落下します。
  /// 爆発時のフラッシュ・光の尾・色彩豊かなシェルで本格的な花火を再現。
  /// 大きな節目やクライマックスの演出に。
  static List<Widget> firework({required CelebrationController controller}) {
    return [FireworkEffect(controller: controller)];
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
        shapes: const [ParticleShape.sakuraPetal],
        windForce: 0.025,
        densityScale: 0.7,
        fadeOutBegin: 0.8,
      ),
    ];
  }
}
