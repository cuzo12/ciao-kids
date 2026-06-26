import '../../domain/entities/story.dart';
import '../../domain/entities/story_choice.dart';
import '../../domain/entities/story_node.dart';

/// The bundled, hand-authored interactive stories.
abstract final class StoryCatalog {
  /// All stories.
  static const List<Story> stories = <Story>[_roma];

  static const Story _roma = Story(
    id: 'story_roma',
    title: 'Un giorno a Roma',
    subtitle: 'Explore Rome — your choices change the adventure',
    emoji: '🏛️',
    startNodeId: 'start',
    nodes: <String, StoryNode>{
      'start': StoryNode(
        id: 'start',
        emoji: '✈️',
        narrationItalian: 'Benvenuto a Roma! Dove vuoi andare?',
        narrationEnglish: 'Welcome to Rome! Where do you want to go?',
        choices: <StoryChoice>[
          StoryChoice(
            label: 'Andiamo al Colosseo!',
            keywords: <String>['colosseo', 'andiamo'],
            nextNodeId: 'colosseo',
          ),
          StoryChoice(
            label: 'Voglio un gelato',
            keywords: <String>['gelato', 'gelateria'],
            nextNodeId: 'gelateria',
          ),
        ],
      ),
      'colosseo': StoryNode(
        id: 'colosseo',
        emoji: '🏟️',
        narrationItalian: 'Che meraviglia, il Colosseo è enorme! Cosa facciamo?',
        narrationEnglish: 'How amazing, the Colosseum is huge! What shall we do?',
        choices: <StoryChoice>[
          StoryChoice(
            label: 'Faccio una foto',
            keywords: <String>['foto'],
            nextNodeId: 'end_foto',
          ),
          StoryChoice(
            label: 'Voglio esplorare',
            keywords: <String>['esplora', 'esplorare'],
            nextNodeId: 'end_gatto',
          ),
        ],
      ),
      'gelateria': StoryNode(
        id: 'gelateria',
        emoji: '🍨',
        narrationItalian: 'Siamo in gelateria! Quale gusto vuoi?',
        narrationEnglish: "We're at the gelato shop! Which flavor do you want?",
        choices: <StoryChoice>[
          StoryChoice(
            label: 'Cioccolato!',
            keywords: <String>['cioccolato'],
            nextNodeId: 'end_cioccolato',
          ),
          StoryChoice(
            label: 'Fragola!',
            keywords: <String>['fragola'],
            nextNodeId: 'end_fragola',
          ),
        ],
      ),
      'end_foto': StoryNode(
        id: 'end_foto',
        emoji: '📸',
        narrationItalian: 'Che bella foto! La mandiamo alla famiglia. Fine!',
        narrationEnglish: 'What a great photo! We send it to the family. The End!',
        isEnding: true,
      ),
      'end_gatto': StoryNode(
        id: 'end_gatto',
        emoji: '🐱',
        narrationItalian: 'Esplorando, troviamo un gattino simpatico! Fine!',
        narrationEnglish: 'While exploring, we find a friendly kitten! The End!',
        isEnding: true,
      ),
      'end_cioccolato': StoryNode(
        id: 'end_cioccolato',
        emoji: '🍫',
        narrationItalian: 'Mmm, cioccolato! Che delizia. Fine!',
        narrationEnglish: 'Mmm, chocolate! How delicious. The End!',
        isEnding: true,
      ),
      'end_fragola': StoryNode(
        id: 'end_fragola',
        emoji: '🍓',
        narrationItalian: 'La fragola è squisita! Che giornata. Fine!',
        narrationEnglish: 'The strawberry is exquisite! What a day. The End!',
        isEnding: true,
      ),
    },
  );
}
