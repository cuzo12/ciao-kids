import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../mastery/data/mastery_service.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../data/coach_profile.dart';
import '../../data/coach_session_service.dart';

/// The AI Language Coach hub: shows goals, generates a personalized lesson,
/// and links to weakness review and Giulia conversations.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final CoachProfileService _profileSvc = sl<CoachProfileService>();
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late CoachProfile _profile;
  Map<String, dynamic>? _session;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    _profile = _profileSvc.load(_uid);
    if (!_profile.setupDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSetup();
      });
    }
  }

  Future<void> _openSetup() async {
    final bool? saved = await context.pushNamed<bool>(Routes.goalSetupName);
    if (saved == true && mounted) {
      setState(() => _profile = _profileSvc.load(_uid));
    }
  }

  Future<void> _generateSession() async {
    setState(() => _loading = true);
    final CoachSessionService svc = CoachSessionService(mastery: _mastery);
    try {
      final Map<String, dynamic> s = await svc.generate(
        userId: _uid,
        profile: _profile,
      );
      context.read<PlayerController>().record(xp: 10, coins: 2);
      setState(() {
        _session = s;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    } finally {
      svc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int seen = _mastery.seenCount(_uid);
    final int mastered = _mastery.masteredCount(_uid);
    final int total = _mastery.poolSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Edit goals',
            onPressed: _openSetup,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            // --- Goal banner ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Your Goal: ${_profile.goalLabel}',
                      style: text.titleLarge?.copyWith(color: Colors.white)),
                  if (_profile.daysUntilTrip != null)
                    Text('${_profile.daysUntilTrip} to go!',
                        style: text.titleMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Level ${_profile.level} · ${_profile.interests.join(", ")}',
                      style: text.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- Mastery stats ---
            Text('Your Progress', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(child: _StatCard(value: '$seen', label: 'Words Seen', color: AppColors.tertiary)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _StatCard(value: '$mastered', label: 'Mastered', color: AppColors.success)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _StatCard(value: '$total', label: 'Total Pool', color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: total > 0 ? mastered / total : 0,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${(total > 0 ? mastered / total * 100 : 0).toStringAsFixed(0)}% mastered',
                style: text.labelMedium,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- Generate lesson ---
            _loading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    label: _session == null ? 'Generate My Lesson' : 'New Lesson',
                    icon: Icons.auto_awesome,
                    onPressed: _generateSession,
                  ),
            const SizedBox(height: AppSpacing.lg),

            // --- AI-generated session ---
            if (_session != null) ...<Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_session!['greeting'] as String? ?? '',
                        style: text.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    Text("Today's Focus Words", style: text.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    for (final Map<String, dynamic> vw
                        in (_session!['vocab'] as List<dynamic>? ?? <dynamic>[]).cast<Map<String, dynamic>>())
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: () => sl<TtsService>().speak(vw['it'] as String? ?? ''),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.tertiary),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: text.bodyLarge,
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: '${vw['it']}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(text: '  —  ${vw['en']}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (((vw['tip'] as String?) ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 26, top: 2),
                                  child: Text("💡 ${vw['tip']}",
                                      style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Exercise', style: text.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_session!['exercise'] as String? ?? '', style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.md),
                    Text('Practice Prompt', style: text.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_session!['conversationPrompt'] as String? ?? '',
                        style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.md),
                    Text(_session!['encouragement'] as String? ?? '',
                        style: text.titleMedium?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (AppConfig.claudeEnabled)
                OutlinedButton.icon(
                  onPressed: () => context.pushNamed(Routes.aiChatName),
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Practice with Giulia'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                  ),
                ),
            ],

            const SizedBox(height: AppSpacing.lg),
            // --- Quick links ---
            Text('Quick Practice', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            _QuickLink(
              emoji: '🧠',
              title: 'Smart Review',
              subtitle: 'Practice your weakest words',
              onTap: () => context.pushNamed(Routes.reviewName),
            ),
            _QuickLink(
              emoji: '🎮',
              title: 'Games',
              subtitle: 'Fun practice with adaptive words',
              onTap: () => context.pushNamed(Routes.gamesName),
            ),
            _QuickLink(
              emoji: '📖',
              title: 'Phrasebook',
              subtitle: 'Real phrases for your trip',
              onTap: () => context.pushNamed(Routes.phrasebookName),
            ),
          ],
        ),
      ),
    );
  }

}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: <Widget>[
          Text(value, style: text.headlineMedium?.copyWith(color: color)),
          Text(label, style: text.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: text.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
