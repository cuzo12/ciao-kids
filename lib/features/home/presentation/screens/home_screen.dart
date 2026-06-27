import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../lessons/domain/entities/lesson.dart';
import '../../../lessons/domain/entities/progress_summary.dart';
import '../../../lessons/presentation/controllers/learning_controller.dart';
import '../../../lessons/presentation/widgets/lesson_card.dart';
import '../widgets/stat_chip.dart';
import '../widgets/word_of_the_day.dart';

/// The child's home dashboard — the authenticated landing screen.
///
/// Binds to the [LearningController]: it shows the gamification header (coins /
/// XP / streak) computed from real progress, a daily-challenge call to action
/// that opens the next lesson, and the lesson catalog as a responsive grid with
/// live lock/star state. Tapping an unlocked lesson opens the lesson player.
class HomeScreen extends StatefulWidget {
  /// Creates the [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Accent palette cycled across the lesson grid.
  static const List<Color> _palette = <Color>[
    AppColors.primary,
    AppColors.tertiary,
    AppColors.secondary,
    AppColors.accent,
  ];

  @override
  void initState() {
    super.initState();
    // Load the current user's lessons + progress after the first frame, so the
    // controller's notifyListeners doesn't fire during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String? userId = context.read<AuthController>().user?.id;
      if (userId != null) {
        context.read<LearningController>().load(userId);
      }
    });
  }

  void _openLesson(Lesson lesson, bool unlocked) {
    if (!unlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Finish the lesson before to unlock ${lesson.title}! 🔒'),
          ),
        );
      return;
    }
    context.pushNamed(
      Routes.lessonName,
      pathParameters: <String, String>{'id': lesson.id},
      extra: lesson,
    );
  }

  Future<void> _confirmSignOut() async {
    final AuthController auth = context.read<AuthController>();
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can always sign back in to keep learning.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (yes ?? false) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LearningController learning = context.watch<LearningController>();
    final String name =
        context.watch<AuthController>().user?.firstName ?? 'friend';
    final TextTheme text = Theme.of(context).textTheme;

    final int columns = Responsive.value<int>(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ciao Kids'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Rewards',
            icon: const Icon(Icons.emoji_events_rounded),
            onPressed: () => context.pushNamed(Routes.rewardsName),
          ),
          IconButton(
            tooltip: 'Parents',
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => context.pushNamed(Routes.parentName),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: learning.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _Header(name: name, summary: learning.summary),
                  ),
                  if (learning.nextLesson != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: _DailyChallengeCard(
                          lesson: learning.nextLesson!,
                          onStart: () =>
                              _openLesson(learning.nextLesson!, true),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: WordOfTheDay(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        children: <Widget>[
                          if (AppConfig.claudeEnabled) ...<Widget>[
                            _ActivityCard(
                              emoji: '✨',
                              title: 'Chat with a real tutor',
                              subtitle: 'Open-ended Italian, powered by AI',
                              color: AppColors.accent,
                              onTap: () =>
                                  context.pushNamed(Routes.aiChatName),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          _ActivityCard(
                            emoji: '📅',
                            title: '30-Day Journey',
                            subtitle: 'Daily lessons — Level 1, 2, 3',
                            color: AppColors.primary,
                            onTap: () => context.pushNamed(Routes.curriculumName),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ActivityCard(
                            emoji: '🎮',
                            title: 'Games',
                            subtitle: 'Scramble, flashcards, fill-in & more',
                            color: AppColors.accent,
                            onTap: () => context.pushNamed(Routes.gamesName),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ActivityCard(
                            emoji: '💬',
                            title: 'Practice Talking',
                            subtitle: 'Chat with your Italian friends',
                            color: AppColors.tertiary,
                            onTap: () => context.pushNamed(Routes.talkName),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ActivityCard(
                            emoji: '🗣️',
                            title: 'Pronunciation',
                            subtitle: 'Say words and get a score',
                            color: AppColors.primary,
                            onTap: () => context.pushNamed(Routes.pronounceName),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ActivityCard(
                            emoji: '📖',
                            title: 'Story Mode',
                            subtitle: 'Your choices change the story',
                            color: AppColors.secondary,
                            onTap: () => context.pushNamed(Routes.storiesName),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text('Lessons', style: text.headlineSmall),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.05,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final Lesson lesson = learning.lessons[index];
                          final bool unlocked = learning.isUnlocked(lesson);
                          return LessonCard(
                            lesson: lesson,
                            unlocked: unlocked,
                            progress: learning.progressFor(lesson.id),
                            color: _palette[index % _palette.length],
                            onTap: () => _openLesson(lesson, unlocked),
                          );
                        },
                        childCount: learning.lessons.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Greeting + gamification header.
class _Header extends StatelessWidget {
  const _Header({required this.name, required this.summary});

  final String name;
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Ciao, $name! 👋', style: text.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text("Ready for today's Italian?", style: text.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              StatChip(
                icon: Icons.monetization_on,
                label: '${summary.totalCoins}',
                color: AppColors.accent,
              ),
              StatChip(
                icon: Icons.star_rounded,
                label: '${summary.totalXp} XP',
                color: AppColors.tertiary,
              ),
              StatChip(
                icon: Icons.local_fire_department,
                label: '${summary.streakDays}-day streak',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The hero "daily challenge" call-to-action card.
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.lesson, required this.onStart});

  final Lesson lesson;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Daily Challenge',
                  style: text.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Up next: ${lesson.title}',
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.tonal(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
          Text(lesson.emoji, style: const TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}

/// A tappable home-screen entry into a practice activity.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Material(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: text.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: text.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
