import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/vocab/vocab_bank.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../mastery/data/mastery_service.dart';
import '../../../player/presentation/controllers/player_controller.dart';

/// Hear an Italian word, pick what it means in English. Trains comprehension.
class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late List<VocabWord> _session;
  late List<String> _options;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    _session = _mastery.draw(_uid, 10);
    if (_session.isEmpty) {
      _finished = true;
    } else {
      _options = _optionsFor(_session[0]);
      _speak();
    }
  }

  List<String> _optionsFor(VocabWord target) {
    final List<String> opts = <String>[
      target.en,
      ..._mastery.distractors(target, 3).map((VocabWord w) => w.en),
    ]..shuffle(Random());
    return opts;
  }

  void _speak() => sl<TtsService>().speak(_session[_index].it);

  void _answer(String choice) {
    if (_selected != null) return;
    final VocabWord word = _session[_index];
    final bool ok = choice == word.en;
    setState(() => _selected = choice);
    if (ok) _correct++;
    _mastery.record(_uid, word.id, ok);

    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_index + 1 < _session.length) {
        setState(() {
          _index++;
          _selected = null;
          _options = _optionsFor(_session[_index]);
        });
        _speak();
      } else {
        if (!_awarded) {
          _awarded = true;
          context.read<PlayerController>().record(xp: 15, coins: 3);
        }
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Listening')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _finished
              ? _Done(correct: _correct, total: _session.length, onDone: () => Navigator.pop(context))
              : Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: (_index + 1) / _session.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${_index + 1} / ${_session.length}', style: text.labelMedium),
                    const Spacer(),
                    Text('Listen and choose:', style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.lg),
                    GestureDetector(
                      onTap: _speak,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up_rounded, size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: _speak,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Play again'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (final String opt in _options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SizedBox(
                          width: double.infinity,
                          height: AppSpacing.buttonHeight,
                          child: OutlinedButton(
                            onPressed: _selected == null ? () => _answer(opt) : null,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _selected == null
                                  ? null
                                  : opt == _session[_index].en
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : opt == _selected
                                          ? AppColors.error.withValues(alpha: 0.2)
                                          : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              ),
                            ),
                            child: Text(opt),
                          ),
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.correct, required this.total, required this.onDone});
  final int correct;
  final int total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('👂', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text('$correct / $total correct', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Your Italian ears are getting sharp! 🎧',
              style: text.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: onDone)),
        ],
      ),
    );
  }
}
