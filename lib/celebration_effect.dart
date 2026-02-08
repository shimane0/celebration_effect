/// 軽量な祝福演出ライブラリ
///
/// 紙吹雪（Confetti）やクラッカー（Cracker）などの祝福演出を
/// 任意のウィジェットにオーバーレイする機能を提供します。
/// 画面サイズやウィジェットサイズに応じて自然な演出に自動調整されます。
///
/// ## 基本的な使い方
/// ```dart
/// import 'package:celebration_effect/celebration_effect.dart';
///
/// final controller = CelebrationController();
///
/// CelebrationOverlay(
///   child: YourContent(),
///   effects: [ConfettiEffect(controller: controller)],
/// );
///
/// controller.play();
/// ```
///
/// ## プリセットの利用
/// ```dart
/// CelebrationOverlay(
///   child: YourContent(),
///   effects: CelebrationPreset.birthday(controller: controller),
/// );
/// ```
library;

export 'src/celebration_controller.dart';
export 'src/celebration_overlay.dart';
export 'src/celebration_preset.dart';
export 'src/confetti_effect.dart';
export 'src/cracker_effect.dart';
export 'src/firework_effect.dart';
export 'src/particle_shape.dart';
export 'src/ripple_effect.dart';
export 'src/spotlight_effect.dart';
export 'src/starburst_effect.dart';
