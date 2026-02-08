import 'package:flutter/material.dart';

/// 子ウィジェットの上に祝福演出を重ねるオーバーレイ
///
/// 子ウィジェットの上に `ConfettiEffect` や `CrackerEffect` を
/// 半透明のレイヤーとして重ねて表示します。
///
/// ## 基本的な使い方
/// ```dart
/// CelebrationOverlay(
///   child: MyContent(),
///   effects: [ConfettiEffect(controller: controller)],
/// )
/// ```
///
/// ## 演出の配置
/// デフォルトでは各演出が子ウィジェットと同サイズに拡張されます。
/// `expandEffects: false` にするか、演出を [Positioned] で
/// 包むことで個別の位置指定も可能です。
///
/// ## パーティクルのクリップ
/// デフォルトでは [Clip.none] のため、パーティクルが子ウィジェットの
/// サイズを超えて表示されます。クリップしたい場合は
/// `clipBehavior: Clip.hardEdge` を指定してください。
class CelebrationOverlay extends StatelessWidget {
  /// オーバーレイを生成
  const CelebrationOverlay({
    super.key,
    required this.child,
    this.effects = const [],
    this.expandEffects = true,
    this.clipBehavior = Clip.none,
  });

  /// 背景として表示する子ウィジェット
  final Widget child;

  /// 上に重ねる演出ウィジェットのリスト
  final List<Widget> effects;

  /// 演出を子サイズに合わせて全域に展開するかどうか
  ///
  /// `true`（デフォルト）の場合、[Positioned] で包まれていない演出は
  /// 自動的に [Positioned.fill] で全域に展開されます。
  final bool expandEffects;

  /// オーバーレイのクリップ設定
  ///
  /// デフォルトは [Clip.none]（クリップしない）。
  /// パーティクルが子のサイズを超えて表示されます。
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final overlayEffects = effects.map((effect) {
      if (!expandEffects || effect is Positioned) {
        return effect;
      }
      return Positioned.fill(child: effect);
    }).toList();

    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: clipBehavior,
      children: [child, ...overlayEffects],
    );
  }
}
