import 'package:flutter/foundation.dart';

/// 演出完了時のコールバック型
typedef CelebrationCompleteCallback = void Function();

/// 祝福演出コントローラー
///
/// 紙吹雪やクラッカーなどの祝福演出の再生・停止を統一的に管理します。
/// 複数の演出ウィジェットで同じコントローラーを共有することで、
/// 同時再生・同時停止が可能です。
///
/// ## 基本的な使い方
/// ```dart
/// final controller = CelebrationController();
///
/// // 再生
/// controller.play();
///
/// // 完了コールバック付きで再生
/// controller.play(onComplete: () => print('完了！'));
///
/// // リピート再生
/// controller.play(repeat: true);
///
/// // 停止
/// controller.stop();
///
/// // 不要になったら破棄
/// controller.dispose();
/// ```
///
/// ## ライフサイクル
///
/// `State.initState` で生成し、`State.dispose` で必ず破棄してください。
/// ```dart
/// late final CelebrationController _controller;
///
/// @override
/// void initState() {
///   super.initState();
///   _controller = CelebrationController();
/// }
///
/// @override
/// void dispose() {
///   _controller.dispose();
///   super.dispose();
/// }
/// ```
class CelebrationController extends ChangeNotifier {
  /// コントローラーを生成
  ///
  /// [duration] は演出の既定再生時間（デフォルト4秒）。
  /// [onComplete] は演出完了時に呼ばれるコールバック。
  CelebrationController({
    Duration duration = const Duration(seconds: 4),
    CelebrationCompleteCallback? onComplete,
  }) : _duration = duration,
       _onComplete = onComplete;

  Duration _duration;
  bool _isPlaying = false;
  bool _repeat = false;
  CelebrationCompleteCallback? _onComplete;

  /// 演出が再生中かどうか
  bool get isPlaying => _isPlaying;

  /// 現在の演出時間
  Duration get duration => _duration;

  /// リピートモードが有効かどうか
  bool get repeat => _repeat;

  /// 演出時間を更新
  ///
  /// 再生中でも即座に反映されます。
  void updateDuration({required Duration duration}) {
    if (_duration == duration) {
      return;
    }
    _duration = duration;
    notifyListeners();
  }

  /// 演出を開始
  ///
  /// - [duration]: 今回の再生のみ時間を変更する場合に指定。
  /// - [repeat]: `true` にするとループ再生。[stop] で停止するまで繰り返します。
  /// - [onComplete]: 演出完了時のコールバック（リピート時は停止後に1回だけ呼ばれます）。
  void play({Duration? duration, bool repeat = false, CelebrationCompleteCallback? onComplete}) {
    if (duration != null) {
      _duration = duration;
    }
    _repeat = repeat;
    if (onComplete != null) {
      _onComplete = onComplete;
    }
    _isPlaying = true;
    notifyListeners();
  }

  /// 演出を停止
  ///
  /// リピートモードも同時に解除されます。
  void stop() {
    if (!_isPlaying) {
      return;
    }
    _isPlaying = false;
    _repeat = false;
    notifyListeners();
  }

  /// 演出の再生/停止を切り替え
  ///
  /// 再生中なら停止、停止中なら再生します。
  void toggle({Duration? duration, bool repeat = false}) {
    if (_isPlaying) {
      stop();
    } else {
      play(duration: duration, repeat: repeat);
    }
  }

  /// アニメーション完了時に内部から呼ばれる
  ///
  /// このメソッドはパッケージ内部の演出ウィジェットから呼び出されます。
  /// 外部から直接呼び出す必要はありません。
  void notifyComplete() {
    if (_repeat) {
      // リピートモード: 再度再生を通知
      notifyListeners();
    } else {
      _isPlaying = false;
      notifyListeners();
      _onComplete?.call();
    }
  }
}
