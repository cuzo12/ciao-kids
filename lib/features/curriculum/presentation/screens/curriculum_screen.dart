import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/curriculum_data.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  Set<int> _completed = <int>{};

  static const String _key = 'ciao_kids.curriculum_done';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? raw = sl<SharedPreferences>().getString(_key);
    if (raw != null) {
      _completed = (jsonDecode(raw) as List<dynamic>).map((dynamic e) => e as int).toSet();
    }
    if (mounted) setState(() {});
  }

  bool _isUnlocked(CurriculumDay day) {
    if (day.day == 1) return true;
    if (day.day == 11) return _completed.containsAll(List<int>.generate(10, (int i) => i + 1));
    if (day.day == 21) return _completed.containsAll(List<int>.generate(20, (int i) => i + 1));
    return _completed.contains(day.day - 1);
  }

  void _open(CurriculumDay day) {
    if (!_isUnlocked(day)) return;
    context.pushNamed(
      Routes.curriculumDayName,
      pathParameters: <String, String>{'day': '${day.day}'},
      extra: day,
    ).then((_) => _load());
  }

  static const List<Color> _levelColors = <Color>[
    AppColors.primary,
    AppColors.tertiary,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('30-Day Journey')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            for (int level = 1; level <= 3; level++) ...<Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: _levelColors[level - 1],
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text('Level $level', style: text.labelLarge?.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    level == 1 ? 'Basics' : level == 2 ? 'Everyday' : 'Real Life',
                    style: text.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final CurriculumDay day in CurriculumData.level(level))
                _DayTile(
                  day: day,
                  unlocked: _isUnlocked(day),
                  completed: _completed.contains(day.day),
                  color: _levelColors[level - 1],
                  onTap: () => _open(day),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.unlocked,
    required this.completed,
    required this.color,
    required this.onTap,
  });

  final CurriculumDay day;
  final bool unlocked;
  final bool completed;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Material(
          color: completed
              ? color.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: unlocked ? onTap : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Text(completed ? '✅' : unlocked ? day.emoji : '🔒',
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Day ${day.day}', style: text.labelMedium),
                        Text(day.title, style: text.titleMedium),
                      ],
                    ),
                  ),
                  if (completed)
                    Icon(Icons.check_circle, color: color, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
