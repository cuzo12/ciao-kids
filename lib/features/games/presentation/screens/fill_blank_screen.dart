import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/game_word_bank.dart';

class FillBlankScreen extends StatefulWidget {
  const FillBlankScreen({super.key});

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  late final List<GameWord> _words;
  int _index = 0;
  int _score = 0;
  String _answer = '';
  bool? _correct;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final List<GameWord> pool = <GameWord>[
      ...GameWordBank.beginner,
      ...GameWordBank.intermediate,
      ...GameWordBank.advanced,
    ].where((GameWord w) => w.sentence != null).toList()
      ..shuffle(Random());
    _words = pool.sublist(0, min(8, pool.length));
  }

  void _check() {
    final bool ok = _answer.trim().toLowerCase() ==
        (_words[_index].sentenceAnswer ?? _words[_index].italian).toLowerCase();
    setState(() {
      _correct = ok;
      if (ok) _score++;
    });
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_index + 1 < _words.length) {
        setState(() { _index++; _answer = ''; _correct = null; });
      } else {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fill in the Blank')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _finished
              ? _Done(score: _score, total: _words.length, onDone: () => Navigator.pop(context))
              : Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: (_index + 1) / _words.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${_index + 1} / ${_words.length}', style: text.labelMedium),
                    const Spacer(),
                    Text(_words[_index].emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('(${_words[_index].english})', style: text.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Text(
                        _words[_index].sentence ?? '',
                        style: text.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: 280,
                      child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.center,
                        onChanged: (String v) => _answer = v,
                        onSubmitted: (_) => _check(),
                        decoration: InputDecoration(
                          hintText: 'Fill in the blank…',
                          suffixIcon: _correct == null
                              ? null
                              : Icon(
                                  _correct! ? Icons.check_circle : Icons.cancel,
                                  color: _correct! ? AppColors.success : AppColors.error,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(width: 200, child: PrimaryButton(label: 'Check', onPressed: _check)),
                    if (_correct == false)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Answer: ${_words[_index].sentenceAnswer ?? _words[_index].italian}',
                          style: text.bodyMedium?.copyWith(color: AppColors.secondary),
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
  const _Done({required this.score, required this.total, required this.onDone});
  final int score;
  final int total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('📝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text('$score / $total correct!', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: onDone)),
        ],
      ),
    );
  }
}
