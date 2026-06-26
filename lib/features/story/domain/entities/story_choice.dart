import 'package:equatable/equatable.dart';

/// A branch the child can take from a story node.
///
/// [keywords] let the choice be selected by voice (lenient match against the
/// speech transcript); [label] is the tappable text; [nextNodeId] is where the
/// story goes next.
class StoryChoice extends Equatable {
  /// Creates a [StoryChoice].
  const StoryChoice({
    required this.label,
    required this.keywords,
    required this.nextNodeId,
  });

  /// The tappable/spoken choice text (Italian).
  final String label;

  /// Keyword fragments that match this choice when spoken.
  final List<String> keywords;

  /// Id of the node this choice leads to.
  final String nextNodeId;

  @override
  List<Object?> get props => <Object?>[label, keywords, nextNodeId];
}
