import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../data/sentence_data.dart';

/// Build the Italian sentence by tapping the scrambled words into order.
class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({super.key});

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

/// A word tile in the bank (tracked by id so duplicate words work).
class _Tile {
  _Tile(this.id, this.word);
  final int id;
  final String word;
  bool used = false;
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  final Random _rng = Random();
  late final List<SentenceItem> _round;
  int _index = 0;
  int _correct = 0;
  bool _finished = false;
  bool _awarded = false;

  late List<_Tile> _bank;
  final List<_Tile> _built = <_Tile>[];
  bool? _result;

  @override
  void initState() {
    super.initState();
    _round = List<SentenceItem>.of(SentenceBank.sentences)..shuffle(_rng);
    _round.removeRange(min(8, _round.length), _round.length);
    _setup();
  }

  void _setup() {
    final List<String> words = _round[_index].words;
    _bank = <_Tile>[for (int i = 0; i < words.length; i++) _Tile(i, words[i])];
    // Shuffle until the bank isn't already in the right order.
    do {
      _bank.shuffle(_rng);
    } while (words.length > 1 && _bank.map((_Tile t) => t.word).join(' ') == words.join(' '));
    _built.clear();
    _result = null;
  }

  void _pick(_Tile t) {
    if (t.used || _result != null) return;
    setState(() {
      t.used = true;
      _built.add(t);
    });
  }

  void _unpick(_Tile t) {
    if (_result != null) return;
    setState(() {
      t.used = false;
      _built.remove(t);
    });
  }

  void _check() {
    final String attempt = _built.map((_Tile t) => t.word.toLowerCase()).join(' ');
    final String answer = _round[_index].words.map((String w) => w.toLowerCase()).join(' ');
    final bool ok = attempt == answer;
    setState(() => _result = ok);
    if (ok) {
      _correct++;
      sl<TtsService>().speak(_round[_index].italian);
    }
    Future<void>.delayed(Duration(milliseconds: ok ? 1100 : 1500), () {
      if (!mounted) return;
      if (_index + 1 < _round.length) {
        setState(() {
          _index++;
          _setup();
        });
      } else {
        if (!_awarded) {
          _awarded = true;
          sl<PlayerController>().record(xp: 20, coins: 4);
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
        appBar: AppBar(title: const Text('Sentence Builder')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('$_correct / ${_round.length} sentences!', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('You\'re building real Italian! 🇮🇹', style: text.bodyLarge),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      );
    }

    final SentenceItem s = _round[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Sentence Builder')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              LinearProgressIndicator(
                value: (_index + 1) / _round.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(s.emoji, style: const TextStyle(fontSize: 44)),
              Text('Build:', style: text.labelLarge),
              Text('"${s.english}"', style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),

              // The sentence the child is assembling.
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _result == null
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : _result!
                          ? AppColors.success.withValues(alpha: 0.18)
                          : AppColors.error.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final _Tile t in _built)
                      _WordChip(label: t.word, onTap: () => _unpick(t), filled: true),
                  ],
                ),
              ),
              if (_result == false)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text('It was: ${s.italian}',
                      style: text.bodyMedium?.copyWith(color: AppColors.secondary)),
                ),
              const SizedBox(height: AppSpacing.lg),

              // The scrambled word bank.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final _Tile t in _bank)
                    if (!t.used)
                      _WordChip(label: t.word, onTap: () => _pick(t), filled: false),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Check',
                  onPressed: _built.length == s.words.length && _result == null ? _check : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.label, required this.onTap, required this.filled});
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: filled ? AppColors.tertiary : AppColors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            label,
            style: text.titleMedium?.copyWith(color: filled ? Colors.white : null),
          ),
        ),
      ),
    );
  }
}
