import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../data/conjugation_data.dart';

/// Verb trainer: a Learn tab (browse conjugation tables, tap to hear) and a
/// Practice tab (quiz the most useful forms).
class VerbsScreen extends StatelessWidget {
  const VerbsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verbs'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Present'),
              Tab(text: 'Past'),
              Tab(text: 'Practice'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: <Widget>[
              _TablesTab(past: false),
              _TablesTab(past: true),
              _PracticeTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TablesTab extends StatelessWidget {
  const _TablesTab({required this.past});

  /// Whether to show the passato prossimo (past) instead of the present tense.
  final bool past;

  /// Drop the "/a" / "/e" agreement hint before speaking aloud.
  String _spoken(String form) => form.split('/').first;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(
            past
                ? 'The past tense — "I ate, I went". Perfect for talking about your day. (Girls add -a where you see /a.)'
                : 'These verbs build real sentences. Tap a verb to see how it changes.',
            style: text.bodyLarge,
          ),
        ),
        for (final Verb v in Conjugations.verbs)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExpansionTile(
              title: Text(v.infinitive, style: text.titleLarge),
              subtitle: Text(v.english),
              childrenPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              children: <Widget>[
                for (int i = 0; i < 6; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 70,
                          child: Text(Conjugations.persons[i], style: text.labelLarge),
                        ),
                        Expanded(
                          child: Text(
                            '${past ? v.past[i] : v.forms[i]}  ·  ${Conjugations.personsEn[i]}',
                            style: text.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded,
                              color: AppColors.tertiary, size: 20),
                          onPressed: () => sl<TtsService>().speak(
                              '${Conjugations.persons[i]} ${_spoken(past ? v.past[i] : v.forms[i])}'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PracticeTab extends StatefulWidget {
  const _PracticeTab();

  @override
  State<_PracticeTab> createState() => _PracticeTabState();
}

class _Question {
  _Question(this.prompt, this.answer, this.options, this.spoken);
  final String prompt;
  final String answer;
  final List<String> options;
  final String spoken;
}

class _PracticeTabState extends State<_PracticeTab> {
  final Random _rng = Random();
  late final List<_Question> _questions;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _questions = List<_Question>.generate(8, (_) => _make());
  }

  _Question _make() {
    final Verb v = Conjugations.verbs[_rng.nextInt(Conjugations.verbs.length)];
    final int p = _rng.nextInt(6);
    final String answer = v.forms[p];
    final String base = v.english.replaceFirst('to ', '');
    final String prompt = 'Which is correct for "${Conjugations.personsEn[p]}" + ($base)?';

    final Set<String> opts = <String>{answer};
    final List<String> pool = Conjugations.allForms..shuffle(_rng);
    for (final String f in pool) {
      if (opts.length >= 4) break;
      opts.add(f);
    }
    final List<String> options = opts.toList()..shuffle(_rng);
    return _Question(prompt, answer, options, '${Conjugations.persons[p]} $answer');
  }

  void _answer(String choice) {
    if (_selected != null) return;
    setState(() => _selected = choice);
    final bool ok = choice == _questions[_index].answer;
    if (ok) _correct++;
    sl<TtsService>().speak(_questions[_index].spoken);
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_index + 1 < _questions.length) {
        setState(() {
          _index++;
          _selected = null;
        });
      } else {
        if (!_awarded) {
          _awarded = true;
          sl<PlayerController>().record(xp: 15, coins: 3);
        }
        setState(() => _finished = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (_finished) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('💪', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.md),
            Text('$_correct / ${_questions.length} correct', style: text.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              child: PrimaryButton(
                label: 'Practice again',
                onPressed: () => setState(() {
                  _questions
                    ..clear()
                    ..addAll(List<_Question>.generate(8, (_) => _make()));
                  _index = 0;
                  _correct = 0;
                  _selected = null;
                  _finished = false;
                  _awarded = false;
                }),
              ),
            ),
          ],
        ),
      );
    }

    final _Question q = _questions[_index];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('${_index + 1} / ${_questions.length}', style: text.labelMedium),
          const Spacer(),
          Text(q.prompt, style: text.headlineSmall, textAlign: TextAlign.center),
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
    );
  }
}
