// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:celebration_effect/celebration_effect.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CelebrationDemo());

/// celebration_effect デモアプリ
class CelebrationDemo extends StatelessWidget {
  const CelebrationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebration Effect Demo',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

/// デモ画面
class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final CelebrationController _controller;
  _PresetType _selectedPreset = _PresetType.spotlight;

  @override
  void initState() {
    super.initState();
    _controller = CelebrationController(onComplete: () => print('演出完了！'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildEffects() {
    switch (_selectedPreset) {
      case _PresetType.spotlight:
        return CelebrationPreset.spotlight(controller: _controller);
      case _PresetType.achievement:
        return CelebrationPreset.achievement(controller: _controller);
      case _PresetType.gentle:
        return CelebrationPreset.gentle(controller: _controller);
      case _PresetType.firework:
        return CelebrationPreset.firework(controller: _controller);
      case _PresetType.sakura:
        return CelebrationPreset.sakura(controller: _controller);
      case _PresetType.custom:
        return [
          ConfettiEffect(
            controller: _controller,
            shapes: const [ParticleShape.star, ParticleShape.circle, ParticleShape.streamer],
            colors: const [Colors.amber, Colors.deepOrange, Colors.teal, Colors.indigo],
            windForce: 0.02,
            fadeOutBegin: 0.85,
          ),
          CrackerEffect(
            controller: _controller,
            blastDirection: -math.pi / 4,
            originAlignment: const Alignment(-0.9, 0.9),
            shapes: const [ParticleShape.star, ParticleShape.triangle],
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CelebrationOverlay(
      effects: _buildEffects(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Celebration Effect Demo')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // プリセット選択
              const Text('プリセット:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _PresetType.values.map((preset) {
                  return ChoiceChip(
                    label: Text(preset.label),
                    selected: _selectedPreset == preset,
                    onSelected: (_) => setState(() => _selectedPreset = preset),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // コントロールボタン
              const Text('コントロール:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => _controller.play(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('再生'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _controller.play(repeat: true),
                    icon: const Icon(Icons.repeat),
                    label: const Text('リピート'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _controller.stop(),
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _controller.toggle(),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('トグル'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 状態表示
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Text(
                    '状態: ${_controller.isPlaying ? "再生中" : "停止中"}'
                    '${_controller.repeat ? " (リピート)" : ""}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PresetType {
  spotlight('Spotlight'),
  achievement('Achievement'),
  gentle('Gentle'),
  firework('Fireworks'),
  sakura('Sakura'),
  custom('Custom');

  const _PresetType(this.label);
  final String label;
}
