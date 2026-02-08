/// パーティクルの描画形状
///
/// 演出で生成される各パーティクルの見た目を定義します。
/// `ConfettiEffect` や `CrackerEffect` の `shapes` パラメータに
/// 複数指定すると、ランダムに選ばれたバリエーション豊かな演出になります。
///
/// ```dart
/// ConfettiEffect(
///   controller: controller,
///   shapes: [
///     ParticleShape.rectangle,
///     ParticleShape.circle,
///     ParticleShape.star,
///   ],
/// )
/// ```
enum ParticleShape {
  /// 矩形（デフォルト）
  ///
  /// 紙吹雪の定番形状。3D回転との組み合わせでひらひら舞う動きを演出します。
  rectangle,

  /// 円形
  ///
  /// 丸い紙吹雪。柔らかく可愛らしい印象の演出に適しています。
  circle,

  /// 三角形
  ///
  /// 三角形のパーティクル。幾何学的なアクセントを加えます。
  triangle,

  /// 星形（五芒星）
  ///
  /// 星形のパーティクル。お祝い感を強調したい場面に。
  star,

  /// リボン（細長い帯）
  ///
  /// 細長く揺れる帯状のパーティクル。風になびく動きが特徴です。
  streamer,
}
