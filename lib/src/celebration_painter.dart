import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'particle.dart';
import 'particle_shape.dart';

/// パーティクル描画用カスタムペインター（内部使用）
class CelebrationPainter extends CustomPainter {
  CelebrationPainter({required this.particles, required this.progress, required this.fadeOutBegin});

  final List<Particle> particles;
  final double progress;
  final double fadeOutBegin;

  @override
  void paint(Canvas canvas, Size size) {
    final fadeRange = 1.0 - fadeOutBegin;
    final opacity = fadeRange <= 0
        ? 1.0
        : progress < fadeOutBegin
        ? 1.0
        : (1.0 - progress) / fadeRange;
    final clampedOpacity = opacity.clamp(0.0, 1.0);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: clampedOpacity)
        ..style = PaintingStyle.fill;

      final cosX = math.cos(particle.angleX);
      final sinX = math.sin(particle.angleX);
      final cosY = math.cos(particle.angleY);
      final sinY = math.sin(particle.angleY);
      final cosZ = particle.rotateZ ? math.cos(particle.angleZ) : 1.0;
      final sinZ = particle.rotateZ ? math.sin(particle.angleZ) : 0.0;

      // 3D回転 + 平行移動の変換行列
      final matrix = Matrix4(
        cosY * cosZ,
        cosX * sinZ + sinX * sinY * cosZ,
        sinX * sinZ - cosX * sinY * cosZ,
        0,
        -cosY * sinZ,
        cosX * cosZ - sinX * sinY * sinZ,
        sinX * cosZ + cosX * sinY * sinZ,
        0,
        sinY,
        -sinX * cosY,
        cosX * cosY,
        0.001,
        particle.x,
        particle.y,
        0,
        1,
      );

      final path = _buildShapePath(particle);
      final transformedPath = path.transform(matrix.storage);
      canvas.drawPath(transformedPath, paint);
    }
  }

  /// パーティクルの形状に応じた [Path] を生成
  Path _buildShapePath(Particle particle) {
    final w = particle.width;
    final h = particle.height;

    switch (particle.shape) {
      case ParticleShape.rectangle:
        return Path()
          ..moveTo(0, 0)
          ..lineTo(-w, 0)
          ..lineTo(-w, h)
          ..lineTo(0, h)
          ..close();

      case ParticleShape.circle:
        return Path()..addOval(Rect.fromCenter(center: Offset.zero, width: w, height: h));

      case ParticleShape.triangle:
        return Path()
          ..moveTo(0, -h / 2)
          ..lineTo(-w / 2, h / 2)
          ..lineTo(w / 2, h / 2)
          ..close();

      case ParticleShape.star:
        return _buildStarPath(outerRadius: w / 2);

      case ParticleShape.streamer:
        // リボン状の細長い形状（波打つ帯）
        final sw = w * 0.3;
        final sh = h * 2.5;
        return Path()
          ..moveTo(0, 0)
          ..lineTo(-sw, 0)
          ..lineTo(-sw * 0.8, sh * 0.5)
          ..lineTo(-sw, sh)
          ..lineTo(0, sh)
          ..lineTo(-sw * 0.2, sh * 0.5)
          ..close();
    }
  }

  /// 五芒星のパスを生成
  Path _buildStarPath({required double outerRadius}) {
    final path = Path();
    final innerRadius = outerRadius * 0.5;
    const points = 5;
    const angle = math.pi / points;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final a = i * angle - math.pi / 2;
      final x = r * math.cos(a);
      final y = r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }
}
