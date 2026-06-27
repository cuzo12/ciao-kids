import 'package:flutter/material.dart';

import '../../data/avatar_catalog.dart';
import '../controllers/player_controller.dart';

/// Renders the composed avatar (base + optional hat + optional pet) at [size].
class AvatarView extends StatelessWidget {
  const AvatarView({required this.player, this.size = 80, super.key});

  final PlayerController player;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String base = player.equippedEmoji(AvatarSlot.base);
    final String hat = player.equippedEmoji(AvatarSlot.hat);
    final String pet = player.equippedEmoji(AvatarSlot.pet);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Text(base, style: TextStyle(fontSize: size * 0.7)),
          if (hat.isNotEmpty)
            Positioned(
              top: -size * 0.04,
              child: Text(hat, style: TextStyle(fontSize: size * 0.42)),
            ),
          if (pet.isNotEmpty)
            Positioned(
              bottom: -size * 0.02,
              right: -size * 0.02,
              child: Text(pet, style: TextStyle(fontSize: size * 0.38)),
            ),
        ],
      ),
    );
  }
}
