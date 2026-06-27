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

/// Memory / concentration: flip cards to match each Italian word to its emoji.
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _Card {
  _Card(this.word, this.face);
  final VocabWord word;
  final String face; // emoji or the Italian word
  bool matched = false;
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final MasteryService _mastery = sl<MasteryService>();
  late final String _uid;
  late final List<_Card> _cards;
  final List<int> _revealed = <int>[];
  bool _busy = false;
  int _moves = 0;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthController>().user?.id ?? 'guest';
    final List<VocabWord> words = _mastery.draw(_uid, 6, needEmoji: true);
    _cards = <_Card>[
      for (final VocabWord w in words) ...<_Card>[_Card(w, w.emoji), _Card(w, w.it)],
    ]..shuffle();
  }

  bool get _done => _cards.every((_Card c) => c.matched);

  void _tap(int i) {
    if (_busy || _cards[i].matched || _revealed.contains(i)) return;
    setState(() => _revealed.add(i));
    if (_revealed.length < 2) return;

    _moves++;
    final _Card a = _cards[_revealed[0]];
    final _Card b = _cards[_revealed[1]];
    if (a.word.id == b.word.id) {
      _mastery.record(_uid, a.word.id, true);
      setState(() {
        a.matched = true;
        b.matched = true;
        _revealed.clear();
      });
      if (_done && !_awarded) {
        _awarded = true;
        context.read<PlayerController>().record(xp: 15, coins: 3);
      }
    } else {
      _busy = true;
      Future<void>.delayed(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        setState(() {
          _revealed.clear();
          _busy = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memory Match')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: AppSpacing.md),
                Text('All matched in $_moves moves!', style: text.headlineMedium),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(width: 200, child: PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: <Widget>[
              Text('Match each word to its picture', style: text.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (BuildContext context, int i) {
                    final _Card c = _cards[i];
                    final bool up = c.matched || _revealed.contains(i);
                    return GestureDetector(
                      onTap: () => _tap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: c.matched
                              ? AppColors.success.withValues(alpha: 0.18)
                              : up
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : AppColors.primary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: up
                            ? FittedBox(
                                child: Text(
                                  c.face,
                                  textAlign: TextAlign.center,
                                  style: c.face.length <= 3
                                      ? const TextStyle(fontSize: 40)
                                      : text.titleMedium,
                                ),
                              )
                            : const Icon(Icons.help_outline_rounded, color: Colors.white, size: 32),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
