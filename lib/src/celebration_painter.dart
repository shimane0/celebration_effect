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

      case ParticleShape.sakuraPetal:
        return _buildSakuraPetalPath(width: w, height: h);

      case ParticleShape.beam:
        return _buildBeamPath(width: w, height: h);
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

  /// 桜の花びらのパスを生成
  ///
  /// 先端が尖り付け根がくびれた、自然な花弁のシルエット。
  /// 2つの二次ベジェ曲線で左右対称に描画する。
  Path _buildSakuraPetalPath({required double width, required double height}) {
    // 花びらの縦横比を自然な形に調整
    final pw = width * 1.1;
    final ph = height * 1.6;
    final halfW = pw / 2;

    return Path()
      // 先端（上）から右側の曲線
      ..moveTo(0, -ph / 2)
      ..quadraticBezierTo(halfW * 1.4, -ph * 0.15, halfW * 0.7, ph * 0.2)
      // 右側から付け根（下）へ — くびれを作る
      ..quadraticBezierTo(halfW * 0.15, ph * 0.35, 0, ph / 2)
      // 付け根から左側の曲線
      ..quadraticBezierTo(-halfW * 0.15, ph * 0.35, -halfW * 0.7, ph * 0.2)
      // 左側から先端へ戻る
      ..quadraticBezierTo(-halfW * 1.4, -ph * 0.15, 0, -ph / 2)
      ..close();
  }

  /// 光線ビームのパスを生成
  ///
  /// 両端が尖る細長いダイヤモンド形。
  /// スポットライトの光の筋を再現する。
  Path _buildBeamPath({required double width, required double height}) {
    // 縦長のダイヤモンド形（幅:1 高さ:4のアスペクト比）
    final bw = width * 0.35;
    final bh = height * 2.0;
    final halfW = bw / 2;
    final halfH = bh / 2;

    return Path()
      // 上端（尖る）
      ..moveTo(0, -halfH)
      // 右側への曲線
      ..quadraticBezierTo(halfW, -halfH * 0.3, halfW, 0)
      // 下端（尖る）
      ..quadraticBezierTo(halfW, halfH * 0.3, 0, halfH)
      // 左側への曲線
      ..quadraticBezierTo(-halfW, halfH * 0.3, -halfW, 0)
      // 上端へ戻る
      ..quadraticBezierTo(-halfW, -halfH * 0.3, 0, -halfH)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particles != particles;
  }
}
