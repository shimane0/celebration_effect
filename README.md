# celebration_effect

軽量な祝福演出ライブラリ。紙吹雪（Confetti）やクラッカー（Cracker）などの
祝福演出を任意のウィジェットにオーバーレイできます。

## 特徴

- **紙吹雪** — 画面上部から降り注ぐカラフルなパーティクル
- **クラッカー** — 指定位置から放射状に発射されるパーティクル
- **スポットライト** — グラデーション描画によるステージ照明風の光のビーム
- **花火** — 複数シェルが時間差で爆発する本格的な花火演出
- **スターバースト** — 中央から光芒が回転拡大する放射状演出
- **リップル** — 同心円の光の波紋が広がる幻想的な演出
- **7種類のパーティクル形状** — 矩形・円・三角・星・リボン・桜・ビーム
- **自動スケーリング** — 画面サイズに応じてパーティクル数/サイズ/運動量を自動調整
- **プリセット** — `spotlight` / `starburst` / `ripple` / `firework` / `sakura` ですぐに使える
- **コントローラー** — 再生/停止/トグル/リピート/完了コールバックを統一管理
- **風エフェクト** — 横方向のドリフトで自然な動きを実現
- **フェードアウト制御** — 開始タイミングをカスタマイズ可能
- **追加パッケージ不要** — Flutter 標準のみで動作

---

## クイックスタート

### 1. 依存関係の追加

```yaml
dependencies:
  celebration_effect:
    path: ./celebration_effect  # またはpub.devのバージョン指定
```

### 2. 最小構成のコード

```dart
import 'package:celebration_effect/celebration_effect.dart';

// コントローラーを生成（initState等で）
final controller = CelebrationController();

// UIに重ねて配置
CelebrationOverlay(
  child: const Placeholder(),
  effects: [
    ConfettiEffect(controller: controller),
  ],
);

// 再生
controller.play();

// 不要になったらdispose
controller.dispose();
```

---

## プリセットで即座に使う

定義済みプリセットを使えば、パラメータ調整なしで自然な演出を適用できます。

```dart
CelebrationOverlay(
  child: MyContent(),
  effects: CelebrationPreset.spotlight(controller: controller),
);

controller.play();
```

### 利用可能なプリセット

| プリセット | 説明 |
|---|---|
| `CelebrationPreset.spotlight` | 画面下部から光のビームが上方へ照射されるステージ照明風 |
| `CelebrationPreset.starburst` | 中央から光芒が回転拡大＋螺旋スパークル。達成・報酬演出に |
| `CelebrationPreset.ripple` | 同心円の光の波紋が広がる幻想的な演出。控えめな通知に |
| `CelebrationPreset.firework` | 複数シェルが時間差で爆発する花火。クライマックスに |
| `CelebrationPreset.sakura` | ピンク系でゆったり舞い落ちる桜吹雪風。和風テーマに |

---

## 組み込み手順（詳細）

### コントローラーのライフサイクル

```dart
class _MyWidgetState extends State<MyWidget> {
  late final CelebrationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CelebrationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CelebrationOverlay(
      child: _MainContent(),
      effects: [
        ConfettiEffect(controller: _controller),
      ],
    );
  }
}
```

### 再生オプション

```dart
// 基本再生
_controller.play();

// 再生時間を変更（今回のみ）
_controller.play(duration: const Duration(seconds: 6));

// 完了コールバック付き
_controller.play(onComplete: () => debugPrint('演出完了！'));

// リピート再生（stop()で停止するまで繰り返し）
_controller.play(repeat: true);

// 再生/停止をトグル
_controller.toggle();

// 停止
_controller.stop();
```

---

## カスタマイズ例

### パーティクル形状を混ぜる

```dart
ConfettiEffect(
  controller: controller,
  shapes: [
    ParticleShape.rectangle,
    ParticleShape.circle,
    ParticleShape.star,
  ],
)
```

各パーティクルにリストからランダムに形状が割り当てられます。

### 紙吹雪 + 左右クラッカー

```dart
CelebrationOverlay(
  child: _MainContent(),
  effects: [
    ConfettiEffect(
      controller: controller,
      gravity: 0.15,
      particleDrag: 0.04,
      shapes: [ParticleShape.star, ParticleShape.circle],
    ),
    CrackerEffect(
      controller: controller,
      blastDirection: -math.pi / 3,
      originAlignment: const Alignment(-0.95, 0.85),
      maxBlastForce: 35,
      minBlastForce: 18,
    ),
    CrackerEffect(
      controller: controller,
      blastDirection: -2 * math.pi / 3,
      originAlignment: const Alignment(0.95, 0.85),
      maxBlastForce: 35,
      minBlastForce: 18,
    ),
  ],
);
```

### 風エフェクト

```dart
ConfettiEffect(
  controller: controller,
  windForce: 0.03,  // 正:右方向、負:左方向。0.01〜0.05が自然
)
```

### フェードアウト制御

```dart
ConfettiEffect(
  controller: controller,
  fadeOutBegin: 0.9,  // 90%経過後にフェードアウト開始（デフォルト0.7）
)
```

### 画面サイズの基準を変更

```dart
ConfettiEffect(
  controller: controller,
  referenceSize: const Size(390, 844),
  densityScale: 1.2,
);
```

> `referenceSize` は幅・高さともに正の値を指定してください。
> `densityScale` は 0.5〜2.5 が推奨です（内部でクランプされます）。

---

## よくある落とし穴

### オーバーレイのサイズが小さくて表示されない

`ConfettiEffect` / `CrackerEffect` は親のサイズに合わせて描画します。
`SizedBox.shrink()` や高さ0の親に置くと表示されません。
画面全体に被せたい場合は `CelebrationOverlay` を画面サイズで構成してください。

### `controller.play()` を呼んでも再生しない

- `controller` が `dispose()` 済みだと動きません。
- `initState()` で生成し、`dispose()` で必ず破棄してください。
- `play()` 後にウィジェットがツリーに存在していることを確認してください。

### 一部の演出だけ位置指定したい

`CelebrationOverlay` は非 `Positioned` の演出を自動で `Positioned.fill` します。
位置指定したい場合は `Positioned` で包んで渡してください。

### クラッカーの向きが逆に見える

角度はラジアンで指定します。目安：
- 真上: `-math.pi / 2`
- 右上: `-math.pi / 3`
- 左上: `-2 * math.pi / 3`

### 終盤で急に消える

デフォルトでは演出時間の70%経過後にフェードアウトが始まります。
`fadeOutBegin` パラメータで開始タイミングを調整できます。
`1.0` にするとフェードアウトなし（即座に消える）になります。

---

## API リファレンス

### `CelebrationController`

| メソッド | 説明 |
|---|---|
| `play({duration, repeat, onComplete})` | 演出を開始 |
| `stop()` | 演出を停止（リピートも解除） |
| `toggle({duration, repeat})` | 再生/停止を切り替え |
| `updateDuration({required duration})` | 演出時間を更新 |

| プロパティ | 型 | 説明 |
|---|---|---|
| `isPlaying` | `bool` | 再生中かどうか |
| `duration` | `Duration` | 現在の演出時間 |
| `repeat` | `bool` | リピートモードが有効か |

### `ConfettiEffect`

| パラメータ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `controller` | `CelebrationController` | 必須 | 演出コントローラー |
| `numberOfParticles` | `int?` | 自動 | パーティクル数（自動算出） |
| `gravity` | `double` | `0.18` | 重力の強さ（0.0〜1.0） |
| `particleDrag` | `double` | `0.05` | 空気抵抗（0.0〜1.0） |
| `colors` | `List<Color>?` | 8色 | パーティクルの色リスト |
| `originAlignment` | `Alignment` | `topCenter` | 発生位置 |
| `shapes` | `List<ParticleShape>` | `[rectangle]` | パーティクル形状 |
| `fadeOutBegin` | `double` | `0.7` | フェードアウト開始位置 |
| `windForce` | `double` | `0` | 風の強さ |
| `referenceSize` | `Size` | `360×690` | スケーリング基準サイズ |
| `densityScale` | `double` | `1.0` | パーティクル密度の倍率 |
| `horizontalSpread` | `double` | `0.12` | 生成範囲の拡張率 |
| `minParticleSize` | `double` | `6` | 最小サイズ（px） |
| `maxParticleSize` | `double` | `18` | 最大サイズ（px） |

### `CrackerEffect`

| パラメータ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `controller` | `CelebrationController` | 必須 | 演出コントローラー |
| `blastDirection` | `double?` | `-π/2`（真上） | 発射方向（ラジアン） |
| `numberOfParticles` | `int?` | 自動 | パーティクル数（自動算出） |
| `gravity` | `double` | `0.16` | 重力の強さ |
| `particleDrag` | `double` | `0.03` | 空気抵抗 |
| `maxBlastForce` | `double` | `32` | 最大発射力 |
| `minBlastForce` | `double` | `14` | 最小発射力 |
| `colors` | `List<Color>?` | 8色 | パーティクルの色リスト |
| `originAlignment` | `Alignment` | `centerLeft` | 発射位置 |
| `shapes` | `List<ParticleShape>` | `[rectangle]` | パーティクル形状 |
| `fadeOutBegin` | `double` | `0.7` | フェードアウト開始位置 |
| `windForce` | `double` | `0` | 風の強さ |
| `referenceSize` | `Size` | `360×690` | スケーリング基準サイズ |
| `densityScale` | `double` | `1.0` | パーティクル密度の倍率 |

### `ParticleShape`

| 値 | 説明 |
|---|---|
| `rectangle` | 矩形（デフォルト） |
| `circle` | 円形 |
| `triangle` | 三角形 |
| `star` | 星形（五芒星） |
| `streamer` | リボン（細長い帯） |

### `CelebrationOverlay`

| パラメータ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `child` | `Widget` | 必須 | 背景の子ウィジェット |
| `effects` | `List<Widget>` | `[]` | 重ねる演出ウィジェット |
| `expandEffects` | `bool` | `true` | 演出を全域に展開するか |
| `clipBehavior` | `Clip` | `Clip.none` | クリップ設定 |

---

## ライセンス

MIT License
