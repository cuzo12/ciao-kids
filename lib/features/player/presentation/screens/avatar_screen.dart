import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/avatar_catalog.dart';
import '../controllers/player_controller.dart';
import '../widgets/avatar_view.dart';

/// The avatar "closet" — preview, coin balance, and items to buy/equip.
class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController p = context.watch<PlayerController>();
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Avatar'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text('🪙 ${p.coins}', style: text.titleMedium),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: AvatarView(player: p, size: 120),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Section(title: 'Characters', items: AvatarCatalog.bases, player: p),
            _Section(title: 'Hats', items: AvatarCatalog.hats, player: p),
            _Section(title: 'Pets', items: AvatarCatalog.pets, player: p),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, required this.player});
  final String title;
  final List<AvatarItem> items;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: text.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            for (final AvatarItem item in items)
              _ItemTile(item: item, player: player),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.player});
  final AvatarItem item;
  final PlayerController player;

  Future<void> _onTap(BuildContext context) async {
    final bool unlocked = player.isUnlocked(item.id);
    if (unlocked) {
      await player.equip(item);
      return;
    }
    if (player.coins < item.cost) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Not enough coins yet — keep practicing! 💪')));
      return;
    }
    final bool ok = await player.buy(item);
    if (ok) await player.equip(item);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool unlocked = player.isUnlocked(item.id);
    final bool equipped = player.equippedId(item.slot) == item.id;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: equipped
              ? AppColors.primary.withValues(alpha: 0.18)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: equipped ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Column(
          children: <Widget>[
            Opacity(
              opacity: unlocked ? 1 : 0.5,
              child: Text(
                item.emoji.isEmpty ? '🚫' : item.emoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
            const SizedBox(height: 2),
            Text(item.label, style: text.labelMedium, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            if (equipped)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 18)
            else if (unlocked)
              Text('Wear', style: text.labelMedium?.copyWith(color: AppColors.primary))
            else
              Text('🪙 ${item.cost}',
                  style: text.labelMedium?.copyWith(
                    color: player.coins >= item.cost ? AppColors.accent : Theme.of(context).disabledColor,
                  )),
          ],
        ),
      ),
    );
  }
}
