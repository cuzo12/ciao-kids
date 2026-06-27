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
import '../../../sentences/data/sentence_data.dart';

/// Hear an Italian word or sentence, then pick it out of 10 written options.
class SoundMatchScreen extends StatefulWidget {
  const SoundMatchScreen({super.key});

  @override
  State<SoundMatchScreen> createState() => _SoundMatchScreenState();
}

class _Round {
  _Round({required this.spoken, required this.answer, required this.options, this.wordId});
  final String spoken;
  final String answer;
  final List<String> options;
  final String? wordId;
}

class _SoundMatchScreenState extends State<SoundMatchScreen> {
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late final List<_Round> _rounds;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    _rounds = _buildRounds();
    if (_rounds.isEmpty) {
      _finished = true;
    } else {
      _speak();
    }
  }

  List<_Round> _buildRounds() {
    final List<_Round> rounds = <_Round>[];

    // 4 word rounds (10 written words each).
    for (final VocabWord w in _mastery.draw(_uid, 4)) {
      final List<String> opts = <String>[
        w.it,
        ..._mastery.distractors(w, 9).map((VocabWord d) => d.it),
      ]..shuffle();
      rounds.add(_Round(spoken: w.it, answer: w.it, options: opts, wordId: w.id));
    }

    // 4 sentence rounds (10 written sentences each).
    final List<SentenceItem> sents = List<SentenceItem>.of(SentenceBank.sentences)..shuffle();
    for (final SentenceItem s in sents.take(4)) {
      final List<String> others = sents
          .where((SentenceItem x) => x.italian != s.italian)
          .map((SentenceItem x) => x.italian)
          .take(9)
          .toList();
      final List<String> opts = <String>[s.italian, ...others]..shuffle();
      rounds.add(_Round(spoken: s.italian, answer: s.italian, options: opts));
    }

    rounds.shuffle();
    return rounds;
  }

  void _speak() => sl<TtsService>().speak(_rounds[_index].spoken);

  void _answer(String choice) {
    if (_selected != null) return;
    final _Round r = _rounds[_index];
    final bool ok = choice == r.answer;
    setState(() => _selected = choice);
    if (ok) _correct++;
    if (r.wordId != null) _mastery.record(_uid, r.wordId!, ok);

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 < _rounds.length) {
        setState(() {
          _index++;
          _selected = null;
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

    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sound Match')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🔊', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('$_correct / ${_rounds.length} correct', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      );
    }

    final _Round r = _rounds[_index];
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Match')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: LinearProgressIndicator(
                value: (_index + 1) / _rounds.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _speak,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.volume_up_rounded, size: 44, color: Colors.white),
              ),
            ),
            Text('Tap to hear — then pick what you heard', style: text.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  for (final String opt in r.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _selected == null ? () => _answer(opt) : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            backgroundColor: _selected == null
                                ? null
                                : opt == r.answer
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : opt == _selected
                                        ? AppColors.error.withValues(alpha: 0.2)
                                        : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                          ),
                          child: Text(opt, style: text.titleMedium, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
