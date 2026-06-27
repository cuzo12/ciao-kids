import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/coach_profile.dart';

/// Quick onboarding: why are you learning Italian?
class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final CoachProfileService _svc = sl<CoachProfileService>();
  late final String _uid;
  CoachGoal _goal = CoachGoal.travel;
  DateTime? _tripDate;
  int _level = 1;
  final Set<String> _interests = <String>{'food', 'travel'};

  static const List<String> _allInterests = <String>[
    'food', 'travel', 'sports', 'animals', 'music', 'school', 'family', 'shopping',
  ];
  static const Map<String, String> _interestEmoji = <String, String>{
    'food': '🍕', 'travel': '✈️', 'sports': '⚽', 'animals': '🐾',
    'music': '🎵', 'school': '📚', 'family': '👨‍👩‍👧‍👦', 'shopping': '🛍️',
  };

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    final CoachProfile existing = _svc.load(_uid);
    if (existing.setupDone) {
      _goal = existing.goal;
      _level = existing.level;
      _interests.addAll(existing.interests);
      if (existing.tripDate != null) {
        _tripDate = DateTime.tryParse(existing.tripDate!);
      }
    }
  }

  Future<void> _save() async {
    await _svc.save(
      _uid,
      CoachProfile(
        goal: _goal,
        tripDate: _tripDate?.toIso8601String().split('T').first,
        level: _level,
        dailyMinutes: 20,
        interests: _interests.toList(),
        setupDone: true,
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tripDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _tripDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Italian Goals')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text('Why are you learning Italian?', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            for (final CoachGoal g in CoachGoal.values)
              RadioListTile<CoachGoal>(
                value: g,
                groupValue: _goal,
                onChanged: (CoachGoal? v) => setState(() => _goal = v!),
                title: Text(switch (g) {
                  CoachGoal.travel => '✈️  Trip to Italy',
                  CoachGoal.school => '🏫  School / Class',
                  CoachGoal.fun => '🎮  Just for fun',
                  CoachGoal.family => '👨‍👩‍👧  Family heritage',
                }),
              ),
            if (_goal == CoachGoal.travel) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text('When is your trip?', style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_tripDate == null
                    ? 'Pick a date'
                    : '${_tripDate!.month}/${_tripDate!.day}/${_tripDate!.year}'),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Your current level:', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 1, label: Text('Beginner')),
                ButtonSegment<int>(value: 2, label: Text('Some Italian')),
                ButtonSegment<int>(value: 3, label: Text('Intermediate')),
              ],
              selected: <int>{_level},
              onSelectionChanged: (Set<int> v) => setState(() => _level = v.first),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('What topics interest you?', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String i in _allInterests)
                  FilterChip(
                    label: Text('${_interestEmoji[i] ?? ''} $i'),
                    selected: _interests.contains(i),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (bool on) => setState(() {
                      if (on) {
                        _interests.add(i);
                      } else {
                        _interests.remove(i);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Save & Start', icon: Icons.rocket_launch, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
