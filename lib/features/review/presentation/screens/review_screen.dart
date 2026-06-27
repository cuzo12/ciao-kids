import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../games/data/game_word_bank.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../data/review_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _service = sl<ReviewService>();
  late final String _userId;
  late List<GameWord> _session;
  late List<String> _options;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthController>().user?.id ?? 'guest';
    _session = _service.buildSession(_userId);
    if (_session.isEmpty) {
      _finished = true;
    } else {
      _options = _service.buildOptions(_session[0]);
    }
  }

  void _answer(String choice) {
    if (_selected != null) return;
    final GameWord word = _session[_index];
    final bool ok = choice == word.italian;
    setState(() => _selected = choice);
    if (ok) _correct++;
    _service.recordResult(_userId, word.italian, ok);
    sl<TtsService>().speak(word.italian);

    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (_index + 1 < _session.length) {
        setState(() {
          _index++;
          _selected = null;
          _options = _service.buildOptions(_session[_index]);
        });
      } else {
        _award();
        setState(() => _finished = true);
      }
    });
  }

  void _award() {
    if (_awarded) return;
    _awarded = true;
    context.read<PlayerController>().record(xp: 15, coins: 3);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Review')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _finished
              ? _Done(correct: _correct, total: _session.length, onDone: () => Navigator.pop(context))
              : Column(
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: (_index + 1) / _session.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${_index + 1} / ${_session.length}', style: text.labelMedium),
                    const Spacer(),
                    Text(_session[_index].emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('How do you say…', style: text.bodyMedium),
                    Text(_session[_index].english, style: text.displayMedium),
                    const SizedBox(height: AppSpacing.xl),
                    for (final String opt in _options)
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
                                  : opt == _session[_index].italian
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : opt == _selected
                                          ? AppColors.error.withValues(alpha: 0.2)
                                          : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              ),
                            ),
                            child: Text(opt),
                          ),
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
  const _Done({required this.correct, required this.total, required this.onDone});
  final int correct;
  final int total;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('🧠', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text(total == 0 ? 'Nothing to review yet!' : '$correct / $total correct',
              style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            total == 0
                ? 'Play games and lessons first, then come back to review.'
                : 'Words you missed will come back sooner. 💪',
            style: text.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: onDone)),
        ],
      ),
    );
  }
}
