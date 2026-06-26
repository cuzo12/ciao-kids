import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../lessons/domain/entities/lesson.dart';
import '../../../lessons/domain/entities/lesson_stage.dart';
import '../../../lessons/presentation/controllers/learning_controller.dart';
import '../../../stats/domain/entities/practice_stats.dart';
import '../../../stats/domain/usecases/get_practice_stats.dart';

/// The parent area: a simple math gate, then a read-only analytics dashboard.
///
/// Metrics are computed from real stored data (lesson progress + practice
/// stats); "speaking confidence" is a clearly-labeled derived estimate.
class ParentDashboardScreen extends StatefulWidget {
  /// Creates the [ParentDashboardScreen].
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _unlocked = false;
  PracticeStats _stats = PracticeStats.empty;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final String userId = context.read<AuthController>().user?.id ?? 'guest';
    final PracticeStats stats = await sl<GetPracticeStats>()(userId);
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: SafeArea(
        child: _unlocked
            ? _Dashboard(stats: _stats)
            : _ParentGate(onUnlocked: () => setState(() => _unlocked = true)),
      ),
    );
  }
}

/// A small multiplication gate so children don't wander into the dashboard.
class _ParentGate extends StatefulWidget {
  const _ParentGate({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<_ParentGate> {
  final TextEditingController _answer = TextEditingController();
  bool _error = false;

  static const int _expected =
      AppConstants.parentGateLeft * AppConstants.parentGateRight;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() {
    if (int.tryParse(_answer.text.trim()) == _expected) {
      widget.onUnlocked();
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🔒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('For grown-ups', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'What is ${AppConstants.parentGateLeft} × ${AppConstants.parentGateRight}?',
              style: text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _answer,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => _check(),
                decoration: InputDecoration(
                  hintText: 'Answer',
                  errorText: _error ? 'Try again' : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: 160,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _check,
                child: const Text('Enter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The analytics view shown after the gate.
class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.stats});

  final PracticeStats stats;

  int _wordsLearned(LearningController learning) {
    int words = 0;
    for (final Lesson lesson in learning.lessons) {
      final bool done = learning.progressFor(lesson.id)?.completed ?? false;
      if (!done) continue;
      for (final LessonStage stage in lesson.stages) {
        if (stage is VocabularyStage) words += stage.items.length;
      }
    }
    return words;
  }

  int _confidence(LearningController learning) {
    final summary = learning.summary;
    final double ratio = learning.lessons.isEmpty
        ? 0
        : summary.lessonsCompleted / learning.lessons.length;
    final int spoken =
        (stats.conversationsCompleted + stats.storiesCompleted).clamp(0, 5);
    final double value =
        (stats.averagePronunciation * 0.5) + (ratio * 35) + (spoken * 3);
    return value.round().clamp(0, 100);
  }

  String _confidenceLabel(int value) {
    if (value >= 70) return 'Confident';
    if (value >= 40) return 'Growing';
    return 'Getting started';
  }

  @override
  Widget build(BuildContext context) {
    final LearningController learning = context.watch<LearningController>();
    final summary = learning.summary;
    final TextTheme text = Theme.of(context).textTheme;

    final List<Lesson> completed = learning.lessons
        .where((Lesson l) => learning.progressFor(l.id)?.completed ?? false)
        .toList();
    final List<Lesson> strengths = completed
        .where((Lesson l) => (learning.progressFor(l.id)?.bestStars ?? 0) >= 3)
        .toList();
    final List<Lesson> needsPractice = completed
        .where((Lesson l) => (learning.progressFor(l.id)?.bestStars ?? 0) < 2)
        .toList();
    final int confidence = _confidence(learning);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Text('Progress overview', style: text.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.7,
          children: <Widget>[
            _Metric(
                label: 'Lessons completed',
                value: '${summary.lessonsCompleted}/${learning.lessons.length}',
                color: AppColors.primary),
            _Metric(
                label: 'Words learned',
                value: '${_wordsLearned(learning)}',
                color: AppColors.tertiary),
            _Metric(
                label: 'Day streak',
                value: '${summary.streakDays}',
                color: AppColors.secondary),
            _Metric(
                label: 'Minutes practiced',
                value: '${stats.totalPracticeMinutes}',
                color: AppColors.accent),
            _Metric(
                label: 'Pronunciation',
                value: stats.pronunciationAttempts == 0
                    ? '—'
                    : '${stats.averagePronunciation}%',
                color: AppColors.primary),
            _Metric(
                label: 'Stars earned',
                value: '${summary.totalStars}',
                color: AppColors.accent),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Speaking confidence (estimate)', style: text.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: confidence / 100,
            minHeight: 14,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('$confidence/100 · ${_confidenceLabel(confidence)}',
            style: text.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        _ChipSection(
          title: 'Strengths',
          emptyText: 'Earn 3 stars in a lesson to build strengths.',
          lessons: strengths,
          color: AppColors.success,
        ),
        const SizedBox(height: AppSpacing.md),
        _ChipSection(
          title: 'Needs practice',
          emptyText: 'Nothing flagged — great work!',
          lessons: needsPractice,
          color: AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Recommended review', style: text.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          needsPractice.isNotEmpty
              ? 'Revisit: ${needsPractice.map((Lesson l) => l.title).join(', ')}.'
              : learning.nextLesson != null
                  ? 'Try next: ${learning.nextLesson!.title}.'
                  : 'All caught up!',
          style: text.bodyLarge,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(value, style: text.displayMedium?.copyWith(color: color)),
          Text(label, style: text.bodyMedium),
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.emptyText,
    required this.lessons,
    required this.color,
  });

  final String title;
  final String emptyText;
  final List<Lesson> lessons;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: text.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        if (lessons.isEmpty)
          Text(emptyText, style: text.bodyMedium)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final Lesson lesson in lessons)
                Chip(
                  avatar: Text(lesson.emoji),
                  label: Text(lesson.title),
                  backgroundColor: color.withValues(alpha: 0.15),
                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                ),
            ],
          ),
      ],
    );
  }
}
