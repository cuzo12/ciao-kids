import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/vocab/vocab_bank.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../mastery/data/mastery_service.dart';
import '../../../player/presentation/controllers/player_controller.dart';

class EmojiMatchScreen extends StatefulWidget {
  const EmojiMatchScreen({super.key});

  @override
  State<EmojiMatchScreen> createState() => _EmojiMatchScreenState();
}

class _EmojiMatchScreenState extends State<EmojiMatchScreen> {
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late final List<VocabWord> _words;
  late final List<VocabWord> _shuffledEmojis;
  int _score = 0;
  int _attempts = 0;
  String? _selectedWord;
  final Set<String> _matched = <String>{};

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    _words = _mastery.draw(_uid, 6, needEmoji: true);
    _shuffledEmojis = List<VocabWord>.of(_words)..shuffle(Random());
  }

  void _selectWord(String it) => setState(() => _selectedWord = it);

  void _selectEmoji(VocabWord word) {
    if (_selectedWord == null) return;
    _attempts++;
    final bool ok = _selectedWord == word.it;
    // Record against the word the child intended (the selected one).
    _mastery.record(_uid, _selectedWord!, ok);
    if (ok) {
      _score++;
      _matched.add(word.it);
      if (_matched.length == _words.length) {
        sl<PlayerController>().record(xp: 10, coins: 2);
      }
    }
    setState(() => _selectedWord = null);
  }

  bool get _done => _matched.length == _words.length;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Match')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _done
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('🎯', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: AppSpacing.md),
                      Text('All matched!', style: text.headlineMedium),
                      Text('$_score / $_attempts on first try', style: text.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Tap a word, then tap its emoji', style: text.bodyLarge),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Words', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        for (final VocabWord w in _words)
                          if (!_matched.contains(w.it))
                            ChoiceChip(
                              label: Text(w.it),
                              selected: _selectedWord == w.it,
                              selectedColor: AppColors.primary.withValues(alpha: 0.3),
                              onSelected: (_) => _selectWord(w.it),
                            ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('Emojis', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: <Widget>[
                        for (final VocabWord w in _shuffledEmojis)
                          if (!_matched.contains(w.it))
                            GestureDetector(
                              onTap: () => _selectEmoji(w),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: _selectedWord != null
                                        ? AppColors.primary.withValues(alpha: 0.4)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(w.emoji, style: const TextStyle(fontSize: 36)),
                              ),
                            ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Text(
                        'Matched: ${_matched.length} / ${_words.length}',
                        style: text.titleMedium?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
