import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/game_word_bank.dart';

class WordScrambleScreen extends StatefulWidget {
  const WordScrambleScreen({super.key});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  late final List<GameWord> _words;
  int _index = 0;
  int _score = 0;
  String _guess = '';
  bool? _correct;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _words = List<GameWord>.of(
      [...GameWordBank.beginner, ...GameWordBank.intermediate],
    )..shuffle(Random());
    _words.removeRange(min(8, _words.length), _words.length);
  }

  String _scramble(String word) {
    final List<String> chars = word.toLowerCase().split('')..shuffle(Random());
    final String result = chars.join();
    return result == word.toLowerCase() ? _scramble(word) : result;
  }

  void _check() {
    final bool ok =
        _guess.trim().toLowerCase() == _words[_index].italian.toLowerCase();
    setState(() {
      _correct = ok;
      if (ok) _score++;
    });
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_index + 1 < _words.length) {
        setState(() {
          _index++;
          _guess = '';
          _correct = null;
        });
      } else {
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Word Scramble')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _finished
              ? _DoneView(score: _score, total: _words.length, onDone: () => Navigator.pop(context))
              : Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: (_index + 1) / _words.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${_index + 1} / ${_words.length}', style: text.labelMedium),
                    const Spacer(),
                    Text(_words[_index].emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('English: ${_words[_index].english}', style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Text(
                        _scramble(_words[_index].italian),
                        style: text.displayMedium?.copyWith(letterSpacing: 6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: 280,
                      child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.center,
                        onChanged: (String v) => _guess = v,
                        onSubmitted: (_) => _check(),
                        decoration: InputDecoration(
                          hintText: 'Type the word…',
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
                    SizedBox(
                      width: 200,
                      child: PrimaryButton(label: 'Check', onPressed: _check),
                    ),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.score, required this.total, required this.onDone});
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
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text('$score / $total correct!', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(score == total ? 'Perfetto!' : 'Keep practicing!', style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: onDone)),
        ],
      ),
    );
  }
}
