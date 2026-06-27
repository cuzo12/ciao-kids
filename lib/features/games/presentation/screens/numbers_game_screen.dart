import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/italian_number.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../player/presentation/controllers/player_controller.dart';

/// Numbers, money & counting drill — generates endless questions.
class NumbersGameScreen extends StatefulWidget {
  const NumbersGameScreen({super.key});

  @override
  State<NumbersGameScreen> createState() => _NumbersGameScreenState();
}

enum _Kind { numberToWord, priceToWord, hearToNumber }

class _Q {
  _Q(this.kind, this.display, this.answer, this.options, this.spoken, this.audioFirst);
  final _Kind kind;
  final String display; // big thing shown (a number, a price, or 🔊)
  final String answer;
  final List<String> options;
  final String spoken; // Italian to read aloud
  final bool audioFirst; // auto-play on show
}

class _NumbersGameScreenState extends State<NumbersGameScreen> {
  final Random _rng = Random();
  late final List<_Q> _questions;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _questions = List<_Q>.generate(8, (_) => _make());
    if (_questions[0].audioFirst) _speak();
  }

  int _otherThan(Set<int> used) {
    int n;
    do {
      n = _rng.nextInt(101);
    } while (used.contains(n));
    used.add(n);
    return n;
  }

  _Q _make() {
    final _Kind kind = _Kind.values[_rng.nextInt(_Kind.values.length)];
    final Set<int> used = <int>{};
    final int n = _otherThan(used);
    final List<int> distractors = <int>[_otherThan(used), _otherThan(used), _otherThan(used)];

    switch (kind) {
      case _Kind.numberToWord:
        final List<String> opts = <String>[italianNumber(n), ...distractors.map(italianNumber)]..shuffle(_rng);
        return _Q(kind, '$n', italianNumber(n), opts, italianNumber(n), false);
      case _Kind.priceToWord:
        final List<String> opts = <String>[
          '${italianNumber(n)} euro',
          ...distractors.map((int d) => '${italianNumber(d)} euro'),
        ]..shuffle(_rng);
        return _Q(kind, '€$n', '${italianNumber(n)} euro', opts, '${italianNumber(n)} euro', false);
      case _Kind.hearToNumber:
        final List<String> opts = <String>['$n', ...distractors.map((int d) => '$d')]..shuffle(_rng);
        return _Q(kind, '🔊', '$n', opts, italianNumber(n), true);
    }
  }

  void _speak() => sl<TtsService>().speak(_questions[_index].spoken);

  void _answer(String choice) {
    if (_selected != null) return;
    final _Q q = _questions[_index];
    final bool ok = choice == q.answer;
    setState(() => _selected = choice);
    if (ok) _correct++;
    sl<TtsService>().speak(q.spoken);

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 < _questions.length) {
        setState(() {
          _index++;
          _selected = null;
        });
        if (_questions[_index].audioFirst) _speak();
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
        appBar: AppBar(title: const Text('Numbers & Money')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('💶', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('$_correct / ${_questions.length} correct', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      );
    }

    final _Q q = _questions[_index];
    final String prompt = switch (q.kind) {
      _Kind.numberToWord => 'How do you say this number?',
      _Kind.priceToWord => 'How much is it?',
      _Kind.hearToNumber => 'Tap the number you hear',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Numbers & Money')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              LinearProgressIndicator(
                value: (_index + 1) / _questions.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${_index + 1} / ${_questions.length}', style: text.labelMedium),
              const Spacer(),
              Text(prompt, style: text.bodyLarge),
              const SizedBox(height: AppSpacing.md),
              if (q.kind == _Kind.hearToNumber)
                GestureDetector(
                  onTap: _speak,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.volume_up_rounded, size: 50, color: Colors.white),
                  ),
                )
              else
                Text(q.display,
                    style: text.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xl),
              for (final String opt in q.options)
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
                            : opt == q.answer
                                ? AppColors.success.withValues(alpha: 0.2)
                                : opt == _selected
                                    ? AppColors.error.withValues(alpha: 0.2)
                                    : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                      ),
                      child: Text(opt, style: text.titleMedium),
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
