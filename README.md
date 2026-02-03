# celebration_effect

Lightweight celebration effects (confetti and crackers) with a reusable controller.

## できること

- `CelebrationController`で再生/停止/トグルを統一管理
- `ConfettiEffect`（紙吹雪）と`CrackerEffect`（クラッカー）を別ウィジェットで提供
- 画面サイズに応じてパーティクル量/サイズ/運動量を自動スケール
- 追加パッケージ不要（Flutter標準のみ）

---

## 使い方（最小構成）

最もシンプルな実装は、`CelebrationOverlay`に子ウィジェットと演出を渡して
`controller.play()`を呼ぶだけです。
`CelebrationOverlay`は子のサイズに合わせて演出を自動で拡張します。

```dart
import 'package:celebration_effect/celebration_effect.dart';

final controller = CelebrationController();

CelebrationOverlay(
  child: const Placeholder(),
  effects: [
    ConfettiEffect(controller: controller),
  ],
);

controller.play();
```

---

## 組み込み手順（具体例）

### 1. 依存関係の追加

```yaml
dependencies:
  celebration_effect:
    path: ./celebration_effect
```

### 2. コントローラーの用意

```dart
late final CelebrationController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = CelebrationController();
}

@override
void dispose() {
  _confettiController.dispose();
  super.dispose();
}
```

### 3. UIに重ねて配置

```dart
CelebrationOverlay(
  child: _MainContent(),
  effects: [
    ConfettiEffect(controller: _confettiController),
  ],
);
```

### 4. 再生トリガー

```dart
_confettiController.play();
```

---

## よく使うパターン

### 紙吹雪 + 左右クラッカー

```dart
CelebrationOverlay(
  child: _MainContent(),
  effects: [
    ConfettiEffect(
      controller: _confettiController,
      gravity: 0.15,
      particleDrag: 0.04,
    ),
    CrackerEffect(
      controller: _crackerLeftController,
      blastDirection: -math.pi / 3,
      originAlignment: const Alignment(-0.95, 0.85),
      maxBlastForce: 35,
      minBlastForce: 18,
    ),
    CrackerEffect(
      controller: _crackerRightController,
      blastDirection: -2 * math.pi / 3,
      originAlignment: const Alignment(0.95, 0.85),
      maxBlastForce: 35,
      minBlastForce: 18,
    ),
  ],
);
```

### 再生時間を変更する

```dart
controller.play(duration: const Duration(seconds: 6));
```

### 再生/停止をトグル

```dart
controller.toggle();
```

---

## よくある落し穴・引っ掛かりポイント

### 1. オーバーレイのサイズが小さくて表示されない
- `ConfettiEffect` / `CrackerEffect` は親のサイズに合わせて描画します。
- `SizedBox.shrink()`や高さ0の親に置くと表示されません。
- 画面全体に被せたい場合は `CelebrationOverlay` を画面全体で構成してください。

### 2. 一部の演出だけ位置指定したい
- `CelebrationOverlay`は非`Positioned`の演出を自動で`Positioned.fill`します。
- 位置指定したい場合は`Positioned`で包んで渡してください。

### 2. `controller.play()`を呼んでも再生しない
- `controller`が`dispose()`済みだと動きません。
- `initState()`で生成し、`dispose()`で必ず破棄してください。
- `play()`後にウィジェットがツリーに存在していることを確認してください。

### 3. パーティクル数が多すぎる/少なすぎる
- 未指定の場合は画面サイズから自動算出されます。
- 明示的に調整したい場合は `numberOfParticles` を指定してください。

### 4. クラッカーの向きが逆に見える
- 角度はラジアンで指定します。
- 上方向は $-\pi/2$、右上は $-\pi/3$、左上は $-2\pi/3$ が目安です。

### 5. 終盤で急に消える
- 仕様として終盤30%でフェードアウトします。
- フェードアウトを避けたい場合は内部実装の調整が必要です。

---

## API概要

### `CelebrationController`
- `play({Duration? duration})`
- `stop()`
- `toggle({Duration? duration})`
- `updateDuration({required Duration duration})`

### `ConfettiEffect`
- `numberOfParticles`, `gravity`, `particleDrag`, `colors`
- `originAlignment`, `minParticleSize`, `maxParticleSize`, `horizontalSpread`
- `referenceSize`（自動スケーリングの基準サイズ）
- `densityScale`（パーティクル密度の倍率）

### `CrackerEffect`
- `blastDirection`, `numberOfParticles`, `gravity`, `particleDrag`
- `maxBlastForce`, `minBlastForce`, `colors`, `originAlignment`
- `minParticleSize`, `maxParticleSize`
- `referenceSize`（自動スケーリングの基準サイズ）
- `densityScale`（パーティクル密度の倍率）

---

## 画面サイズの調整（参考）

基準サイズはデフォルトで $360 \times 690$ です。必要に応じて
`referenceSize` と `densityScale` で調整できます。

```dart
ConfettiEffect(
  controller: controller,
  referenceSize: const Size(390, 844),
  densityScale: 1.2,
);
```

> 注意: `referenceSize` は幅・高さともに正の値を指定してください。
> `densityScale` は $0.5 \sim 2.5$ 程度が推奨です（内部でクランプされます）。
