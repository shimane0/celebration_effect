import 'dart:math' as math;
import 'dart:ui';

import 'particle_shape.dart';

/// 個々のパーティクルの状態を保持するモデル（内部使用）
class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.width,
    required this.height,
    required this.mass,
    required this.angleX,
    required this.angleY,
    required this.angleZ,
    required this.angularVelocityX,
    required this.angularVelocityY,
    required this.angularVelocityZ,
    this.shape = ParticleShape.rectangle,
    this.rotateZ = true,
    this.swayAmplitude = 0,
    this.swayFrequency = 0,
    this.swayPhase = 0,
    this.initialBoostX = 0,
    this.initialBoostY = 0,
    this.boostFrames = 0,
    this.windForce = 0,
  });

  // ---------------------------------------------------------------------------
  // 位置・速度
  // ---------------------------------------------------------------------------

  double x;
  double y;
  double velocityX;
  double velocityY;

  // ---------------------------------------------------------------------------
  // 見た目
  // ---------------------------------------------------------------------------

  final Color color;
  final double width;
  final double height;
  final ParticleShape shape;

  // ---------------------------------------------------------------------------
  // 物理パラメータ
  // ---------------------------------------------------------------------------

  final double mass;

  // ---------------------------------------------------------------------------
  // 回転
  // ---------------------------------------------------------------------------

  double angleX;
  double angleY;
  double angleZ;
  double angularVelocityX;
  double angularVelocityY;
  double angularVelocityZ;
  final bool rotateZ;

  // ---------------------------------------------------------------------------
  // 揺れ（紙吹雪の横揺れ演出）
  // ---------------------------------------------------------------------------

  final double swayAmplitude;
  final double swayFrequency;
  double swayPhase;

  // ---------------------------------------------------------------------------
  // 初期ブースト（クラッカーの噴射力）
  // ---------------------------------------------------------------------------

  final double initialBoostX;
  final double initialBoostY;
  int boostFrames;

  // ---------------------------------------------------------------------------
  // 風
  // ---------------------------------------------------------------------------

  /// 風による水平方向の力
  final double windForce;

  // ---------------------------------------------------------------------------
  // 内部状態
  // ---------------------------------------------------------------------------

  double _accelerationX = 0;
  double _accelerationY = 0;
  int _frameCount = 0;

  /// 1フレーム分の物理シミュレーションを進める
  void update(double gravity, double drag) {
    _frameCount++;

    // 初期ブースト（クラッカーの噴射力）
    if (_frameCount <= boostFrames && boostFrames > 0) {
      _accelerationX += initialBoostX / mass;
      _accelerationY += initialBoostY / mass;
    }

    // 空気抵抗
    final speed = math.sqrt(velocityX * velocityX + velocityY * velocityY);
    if (speed > 0) {
      final dragMagnitude = drag * speed * speed;
      _accelerationX += -velocityX / speed * dragMagnitude / mass;
      _accelerationY += -velocityY / speed * dragMagnitude / mass;
    }

    // 重力
    _accelerationY += gravity;

    // 風
    _accelerationX += windForce / mass;

    // 速度・位置の更新
    velocityX += _accelerationX;
    velocityY += _accelerationY;
    x += velocityX;
    y += velocityY;

    // 揺れ（紙吹雪の横揺れ）
    if (swayAmplitude > 0) {
      swayPhase += swayFrequency;
      x += math.sin(swayPhase) * swayAmplitude;
    }

    // 回転角の更新
    angleX += angularVelocityX;
    angleY += angularVelocityY;
    if (rotateZ) {
      angleZ += angularVelocityZ;
    }

    // 角速度の減衰
    angularVelocityX *= 0.999;
    angularVelocityY *= 0.999;
    angularVelocityZ *= 0.999;

    // 加速度のリセット（次フレームで再計算）
    _accelerationX = 0;
    _accelerationY = 0;
  }
}
