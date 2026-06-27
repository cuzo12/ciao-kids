/// Avatar customization catalog.
///
/// An avatar is composed of three slots — a base character, an optional hat,
/// and an optional pet — each rendered as an emoji. Items are unlocked by
/// spending coins earned through practice.
enum AvatarSlot { base, hat, pet }

class AvatarItem {
  const AvatarItem({
    required this.id,
    required this.slot,
    required this.emoji,
    required this.label,
    required this.cost,
  });

  final String id;
  final AvatarSlot slot;
  final String emoji;
  final String label;
  final int cost;
}

abstract final class AvatarCatalog {
  static const List<AvatarItem> bases = <AvatarItem>[
    AvatarItem(id: 'base_girl', slot: AvatarSlot.base, emoji: '👧', label: 'Girl', cost: 0),
    AvatarItem(id: 'base_boy', slot: AvatarSlot.base, emoji: '👦', label: 'Boy', cost: 0),
    AvatarItem(id: 'base_robot', slot: AvatarSlot.base, emoji: '🤖', label: 'Robot', cost: 20),
    AvatarItem(id: 'base_cat', slot: AvatarSlot.base, emoji: '🐱', label: 'Kitty', cost: 30),
    AvatarItem(id: 'base_fox', slot: AvatarSlot.base, emoji: '🦊', label: 'Fox', cost: 40),
    AvatarItem(id: 'base_unicorn', slot: AvatarSlot.base, emoji: '🦄', label: 'Unicorn', cost: 60),
    AvatarItem(id: 'base_astro', slot: AvatarSlot.base, emoji: '🧑‍🚀', label: 'Astronaut', cost: 80),
    AvatarItem(id: 'base_wizard', slot: AvatarSlot.base, emoji: '🧙', label: 'Wizard', cost: 100),
  ];

  static const List<AvatarItem> hats = <AvatarItem>[
    AvatarItem(id: 'hat_none', slot: AvatarSlot.hat, emoji: '', label: 'No hat', cost: 0),
    AvatarItem(id: 'hat_cap', slot: AvatarSlot.hat, emoji: '🧢', label: 'Cap', cost: 10),
    AvatarItem(id: 'hat_party', slot: AvatarSlot.hat, emoji: '🎉', label: 'Party', cost: 15),
    AvatarItem(id: 'hat_grad', slot: AvatarSlot.hat, emoji: '🎓', label: 'Graduate', cost: 25),
    AvatarItem(id: 'hat_crown', slot: AvatarSlot.hat, emoji: '👑', label: 'Crown', cost: 50),
  ];

  static const List<AvatarItem> pets = <AvatarItem>[
    AvatarItem(id: 'pet_none', slot: AvatarSlot.pet, emoji: '', label: 'No pet', cost: 0),
    AvatarItem(id: 'pet_dog', slot: AvatarSlot.pet, emoji: '🐶', label: 'Puppy', cost: 20),
    AvatarItem(id: 'pet_butterfly', slot: AvatarSlot.pet, emoji: '🦋', label: 'Butterfly', cost: 25),
    AvatarItem(id: 'pet_parrot', slot: AvatarSlot.pet, emoji: '🦜', label: 'Parrot', cost: 35),
    AvatarItem(id: 'pet_dragon', slot: AvatarSlot.pet, emoji: '🐉', label: 'Dragon', cost: 70),
  ];

  static const List<AvatarItem> all = <AvatarItem>[...bases, ...hats, ...pets];

  static const Set<String> defaultUnlocked = <String>{
    'base_girl', 'base_boy', 'hat_none', 'pet_none',
  };

  static const Map<String, String> defaultEquipped = <String, String>{
    'base': 'base_girl',
    'hat': 'hat_none',
    'pet': 'pet_none',
  };

  static AvatarItem byId(String id) =>
      all.firstWhere((AvatarItem i) => i.id == id, orElse: () => bases.first);

  static String slotKey(AvatarSlot slot) => slot.name;
}
