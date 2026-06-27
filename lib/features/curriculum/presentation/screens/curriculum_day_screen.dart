import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/curriculum_data.dart';

/// Plays one curriculum day: Vocab → Game → Conversation → Quiz → Done.
class CurriculumDayScreen extends StatefulWidget {
  const CurriculumDayScreen({required this.day, super.key});
  final CurriculumDay day;

  @override
  State<CurriculumDayScreen> createState() => _CurriculumDayScreenState();
}

class _CurriculumDayScreenState extends State<CurriculumDayScreen> {
  int _step = 0; // 0=vocab, 1=game, 2=conversation, 3=quiz, 4=done
  int _quizIndex = 0;
  int _quizCorrect = 0;
  int? _selectedAnswer;

  CurriculumDay get day => widget.day;

  void _nextStep() {
    setState(() {
      _step++;
      _quizIndex = 0;
      _quizCorrect = 0;
      _selectedAnswer = null;
    });
  }

  void _answerQuiz(int index) {
    setState(() => _selectedAnswer = index);
    final bool correct = index == day.quizQuestions[_quizIndex].correctIndex;
    if (correct) _quizCorrect++;
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_quizIndex + 1 < day.quizQuestions.length) {
        setState(() { _quizIndex++; _selectedAnswer = null; });
      } else {
        _markComplete();
        setState(() => _step = 4);
      }
    });
  }

  Future<void> _markComplete() async {
    const String key = 'ciao_kids.curriculum_done';
    final SharedPreferences prefs = sl<SharedPreferences>();
    final String? raw = prefs.getString(key);
    final Set<int> done = raw != null
        ? (jsonDecode(raw) as List<dynamic>).map((dynamic e) => e as int).toSet()
        : <int>{};
    done.add(day.day);
    await prefs.setString(key, jsonEncode(done.toList()));
  }

  void _openGame() {
    final String route = switch (day.gameName) {
      'word_scramble' => Routes.wordScrambleName,
      'flashcard' => Routes.flashcardName,
      'fill_blank' => Routes.fillBlankName,
      'emoji_match' => Routes.emojiMatchName,
      _ => Routes.flashcardName,
    };
    context.pushNamed(route).then((_) => _nextStep());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Day ${day.day}: ${day.title}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: switch (_step) {
            0 => _VocabStep(day: day, onNext: _nextStep),
            1 => _GameStep(onPlay: _openGame),
            2 => _ConversationStep(prompt: day.conversationPrompt, onNext: _nextStep),
            3 => _QuizStep(
                  question: day.quizQuestions[_quizIndex],
                  index: _quizIndex,
                  total: day.quizQuestions.length,
                  selected: _selectedAnswer,
                  onAnswer: _answerQuiz,
                ),
            _ => _DoneStep(
                  correct: _quizCorrect,
                  total: day.quizQuestions.length,
                  dayNum: day.day,
                  onDone: () => context.pop(),
                ),
          },
        ),
      ),
    );
  }
}

class _VocabStep extends StatelessWidget {
  const _VocabStep({required this.day, required this.onNext});
  final CurriculumDay day;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Today's Words", style: text.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: day.vocabWords.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final VocabPair w = day.vocabWords[index];
              return Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  onTap: () => sl<TtsService>().speak(w.italian),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: <Widget>[
                        Text(w.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(w.italian, style: text.titleMedium),
                              Text(w.english, style: text.bodyMedium),
                            ],
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, color: AppColors.tertiary, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Next: Play a Game', icon: Icons.games_rounded, onPressed: onNext),
      ],
    );
  }
}

class _GameStep extends StatelessWidget {
  const _GameStep({required this.onPlay});
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🎮', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.md),
          Text('Time to practice!', style: text.headlineMedium),
          Text('Play a quick game to review the words.', style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Play Game', icon: Icons.play_arrow_rounded, onPressed: onPlay),
        ],
      ),
    );
  }
}

class _ConversationStep extends StatelessWidget {
  const _ConversationStep({required this.prompt, required this.onNext});
  final String prompt;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('💬', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.md),
          Text('Conversation Time', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Text(prompt, style: text.bodyLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Try saying this to Giulia in the AI chat!', style: text.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Next: Quiz', icon: Icons.quiz_rounded, onPressed: onNext),
        ],
      ),
    );
  }
}

class _QuizStep extends StatelessWidget {
  const _QuizStep({
    required this.question,
    required this.index,
    required this.total,
    required this.selected,
    required this.onAnswer,
  });

  final CurrQuizQ question;
  final int index;
  final int total;
  final int? selected;
  final void Function(int) onAnswer;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          value: (index + 1) / total,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Question ${index + 1} / $total', style: text.labelMedium),
        const Spacer(),
        Text(question.prompt, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        for (int i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: OutlinedButton(
                onPressed: selected == null ? () => onAnswer(i) : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: selected == null
                      ? null
                      : i == question.correctIndex
                          ? AppColors.success.withValues(alpha: 0.2)
                          : i == selected
                              ? AppColors.error.withValues(alpha: 0.2)
                              : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                child: Text(question.options[i]),
              ),
            ),
          ),
        const Spacer(),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.correct, required this.total, required this.dayNum, required this.onDone});
  final int correct;
  final int total;
  final int dayNum;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🎉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.md),
          Text('Day $dayNum Complete!', style: text.headlineMedium),
          Text('Quiz: $correct / $total', style: text.titleLarge?.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Text(correct == total ? 'Perfetto! 🌟' : 'Great effort! Keep going! 💪', style: text.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: onDone)),
        ],
      ),
    );
  }
}
