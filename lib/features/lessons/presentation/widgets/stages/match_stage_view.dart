import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/lesson_stage.dart';
import '../../../domain/entities/vocabulary_item.dart';

/// Renders a [MatchStage] mini-game: tap an Italian word, then its English
/// meaning, to pair them. Correct pairs lock in green; wrong taps clear the
/// selection so the child can try again.
class MatchStageView extends StatefulWidget {
  /// Creates a [MatchStageView].
  const MatchStageView({required this.stage, super.key});

  /// The pairs to match.
  final MatchStage stage;

  @override
  State<MatchStageView> createState() => _MatchStageViewState();
}

class _MatchStageViewState extends State<MatchStageView> {
  late final List<VocabularyItem> _left = widget.stage.pairs;
  late final List<VocabularyItem> _right =
      List<VocabularyItem>.of(widget.stage.pairs)..shuffle();

  final Set<String> _matched = <String>{};
  int? _selectedLeft;
  int? _wrongRight;

  bool get _complete => _matched.length == _left.length;

  void _onLeftTap(int index) {
    if (_matched.contains(_left[index].italian)) return;
    setState(() {
      _selectedLeft = index;
      _wrongRight = null;
    });
  }

  void _onRightTap(int index) {
    final VocabularyItem right = _right[index];
    if (_matched.contains(right.italian)) return;
    final int? leftIndex = _selectedLeft;
    if (leftIndex == null) return;

    if (_left[leftIndex] == right) {
      setState(() {
        _matched.add(right.italian);
        _selectedLeft = null;
        _wrongRight = null;
      });
    } else {
      setState(() {
        _wrongRight = index;
        _selectedLeft = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _complete
              ? 'Perfetto! All matched! 🎉'
              : 'Match each Italian word to its meaning.',
          style: text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < _left.length; i++)
                      _MatchTile(
                        label: _left[i].italian,
                        matched: _matched.contains(_left[i].italian),
                        selected: _selectedLeft == i,
                        wrong: false,
                        onTap: () => _onLeftTap(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < _right.length; i++)
                      _MatchTile(
                        label: _right[i].english,
                        matched: _matched.contains(_right[i].italian),
                        selected: false,
                        wrong: _wrongRight == i,
                        onTap: () => _onRightTap(i),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single tappable tile in the matching game.
class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.matched,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final Color background;
    if (matched) {
      background = AppColors.success.withValues(alpha: 0.2);
    } else if (wrong) {
      background = AppColors.error.withValues(alpha: 0.2);
    } else if (selected) {
      background = AppColors.primary.withValues(alpha: 0.25);
    } else {
      background = Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: matched ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (matched) ...<Widget>[
                  const Icon(Icons.check, color: AppColors.success, size: 18),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: text.titleMedium,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
