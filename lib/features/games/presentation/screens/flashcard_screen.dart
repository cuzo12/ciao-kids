import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/vocab/vocab_bank.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../mastery/data/mastery_service.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late final List<VocabWord> _words;
  int _index = 0;
  bool _flipped = false;
  int _known = 0;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    _words = _mastery.draw(_uid, 10);
  }

  void _flip() => setState(() => _flipped = !_flipped);

  /// Record this card and advance. [gotIt] feeds the adaptive engine.
  void _advance(bool gotIt) {
    if (gotIt) _known++;
    _mastery.record(_uid, _words[_index].id, gotIt);
    if (_index + 1 < _words.length) {
      setState(() {
        _index++;
        _flipped = false;
      });
    } else {
      sl<PlayerController>().record(xp: 10, coins: 2);
      setState(() => _index++); // past the end → done view
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (_index >= _words.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard Flip')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🃏', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('$_known / ${_words.length} known!', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      );
    }

    final VocabWord w = _words[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard Flip')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              LinearProgressIndicator(
                value: (_index + 1) / _words.length,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${_index + 1} / ${_words.length}', style: text.labelMedium),
              const Spacer(),
              GestureDetector(
                onTap: _flip,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey<String>('$_index-$_flipped'),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _flipped
                          ? AppColors.tertiary.withValues(alpha: 0.18)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: _flipped ? AppColors.tertiary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (w.emoji.isNotEmpty)
                          Text(w.emoji, style: const TextStyle(fontSize: 44)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _flipped ? w.en : w.it,
                          style: text.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(_flipped ? 'English' : 'Italian — tap to flip',
                            style: text.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => sl<TtsService>().speak(w.it),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Hear it'),
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _advance(false),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Tricky'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                        foregroundColor: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _advance(true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Got it!'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
