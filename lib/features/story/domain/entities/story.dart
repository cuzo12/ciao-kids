import 'package:equatable/equatable.dart';

import 'story_node.dart';

/// An interactive, branching story made of [StoryNode]s.
class Story extends Equatable {
  /// Creates a [Story].
  const Story({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.startNodeId,
    required this.nodes,
  });

  /// Stable id used in routes.
  final String id;

  /// Display title.
  final String title;

  /// One-line description for the chooser.
  final String subtitle;

  /// Cover emoji.
  final String emoji;

  /// Id of the opening node.
  final String startNodeId;

  /// All nodes keyed by id.
  final Map<String, StoryNode> nodes;

  /// The opening node.
  StoryNode get start => nodes[startNodeId]!;

  /// Returns the node with [id], or `null` if missing.
  StoryNode? node(String id) => nodes[id];

  @override
  List<Object?> get props =>
      <Object?>[id, title, subtitle, emoji, startNodeId, nodes];
}
