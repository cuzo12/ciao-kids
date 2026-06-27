import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../player/presentation/controllers/player_controller.dart';
import '../../data/game_word_bank.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final List<GameWord> _words;
  int _index = 0;
  bool _flipped = false;
  int _known = 0;

  @override
  void initState() {
    super.initState();
    _words = List<GameWord>.of(
      [...GameWordBank.beginner, ...GameWordBank.intermediate, ...GameWordBank.advanced],
    )..shuffle(Random());
    _words.removeRange(min(10, _words.length), _words.length);
  }

  void _flip() => setState(() => _flipped = !_flipped);

  void _next(bool gotIt) {
    if (gotIt) _known++;
    if (_index + 1 < _words.length) {
      setState(() {
        _index++;
        _flipped = false;
      });
    } else {
      sl<PlayerController>().record(xp: 10, coins: 2);
      setState(() => _index++); // pushes past the deck → shows the done view
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool allDone = _index >= _words.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard Flip')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: allDone
              ? Center(
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
                )
              : Column(
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
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey<String>('$_index-$_flipped'),
                          width: double.infinity,
                          height: 220,
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
                              Text(_words[_index].emoji, style: const TextStyle(fontSize: 48)),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _flipped ? _words[_index].english : _words[_index].italian,
                                style: text.displayMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _flipped ? 'English' : 'Italian — tap to flip',
                                style: text.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_flipped)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton.icon(
                            onPressed: () => _next(false),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Study again'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () => _next(true),
                            icon: const Icon(Icons.check),
                            label: const Text('Got it!'),
                          ),
                        ],
                      )
                    else
                      Text('Tap the card to see the English', style: text.bodyMedium),
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
