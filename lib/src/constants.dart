import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 自動スケーリング基準
// ---------------------------------------------------------------------------

/// 自動スケーリングの既定基準幅
const double defaultReferenceWidth = 360;

/// 自動スケーリングの既定基準高さ
const double defaultReferenceHeight = 690;

/// 自動スケーリングの既定基準面積
const double defaultReferenceArea = defaultReferenceWidth * defaultReferenceHeight;

// ---------------------------------------------------------------------------
// 重力
// ---------------------------------------------------------------------------

/// 重力の最小値（gravity=0.0 に対応）
const double minGravity = 0.04;

/// 重力の最大値（gravity=1.0 に対応）
const double maxGravity = 0.6;

// ---------------------------------------------------------------------------
// 紙吹雪（Confetti）デフォルト値
// ---------------------------------------------------------------------------

const int baseConfettiCount = 160;
const int minConfettiCount = 90;
const int maxConfettiCount = 260;

const double minConfettiSize = 6;
const double maxConfettiSize = 18;

const double minConfettiMass = 1;
const double maxConfettiMass = 8;

const double defaultConfettiGravity = 0.18;
const double defaultConfettiDrag = 0.05;
const double defaultConfettiHorizontalSpread = 0.12;

// ---------------------------------------------------------------------------
// クラッカー（Cracker）デフォルト値
// ---------------------------------------------------------------------------

const int baseCrackerCount = 70;
const int minCrackerCount = 40;
const int maxCrackerCount = 140;

const double minCrackerSize = 6;
const double maxCrackerSize = 24;

const double minCrackerMass = 2;
const double maxCrackerMass = 8;

const double defaultCrackerGravity = 0.16;
const double defaultCrackerDrag = 0.03;

// ---------------------------------------------------------------------------
// 共通デフォルト値
// ---------------------------------------------------------------------------

const double defaultMinBlastForce = 14;
const double defaultMaxBlastForce = 32;

/// デフォルトのフェードアウト開始位置（演出時間の70%経過後）
const double defaultFadeOutBegin = 0.7;

/// 既定のパーティクルカラー（8色）
const List<Color> defaultColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.pink,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
];
