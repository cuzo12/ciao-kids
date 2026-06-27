import 'package:flutter/material.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class _DailyWord {
  const _DailyWord(this.italian, this.english, this.emoji, this.example);
  final String italian;
  final String english;
  final String emoji;
  final String example;
}

const List<_DailyWord> _words = <_DailyWord>[
  _DailyWord('Avventura', 'Adventure', '🗺️', "Oggi è un'avventura!"),
  _DailyWord('Sorriso', 'Smile', '😊', 'Il tuo sorriso è bellissimo.'),
  _DailyWord('Coraggio', 'Courage', '💪', 'Hai molto coraggio.'),
  _DailyWord('Sogno', 'Dream', '💭', 'Il mio sogno è viaggiare.'),
  _DailyWord('Stelle', 'Stars', '⭐', 'Guarda le stelle stasera!'),
  _DailyWord('Amicizia', 'Friendship', '🤝', "L'amicizia è importante."),
  _DailyWord('Tramonto', 'Sunset', '🌅', 'Che bel tramonto!'),
  _DailyWord('Speranza', 'Hope', '🌈', 'La speranza è forte.'),
  _DailyWord('Gentilezza', 'Kindness', '💝', 'La gentilezza cambia il mondo.'),
  _DailyWord('Felicità', 'Happiness', '🎉', 'La felicità è qui.'),
  _DailyWord('Arcobaleno', 'Rainbow', '🌈', "Dopo la pioggia c'è l'arcobaleno."),
  _DailyWord('Musica', 'Music', '🎵', 'La musica mi fa ballare.'),
  _DailyWord('Gioia', 'Joy', '😄', 'Che gioia vederti!'),
  _DailyWord('Libertà', 'Freedom', '🕊️', 'La libertà è preziosa.'),
  _DailyWord('Pace', 'Peace', '☮️', 'Voglio la pace nel mondo.'),
  _DailyWord('Tesoro', 'Treasure', '💎', 'Sei un tesoro!'),
  _DailyWord('Farfalla', 'Butterfly', '🦋', 'La farfalla è colorata.'),
  _DailyWord('Meraviglia', 'Wonder', '✨', 'Che meraviglia!'),
  _DailyWord('Cuore', 'Heart', '❤️', 'Segui il tuo cuore.'),
  _DailyWord('Sapere', 'To know', '🧠', 'Voglio sapere tutto!'),
  _DailyWord('Crescere', 'To grow', '🌱', 'Continua a crescere.'),
  _DailyWord('Insieme', 'Together', '👫', 'Stiamo bene insieme.'),
  _DailyWord('Fiducia', 'Trust', '🤲', 'Ho fiducia in te.'),
  _DailyWord('Scoprire', 'To discover', '🔍', 'Andiamo a scoprire!'),
  _DailyWord('Energia', 'Energy', '⚡', 'Hai tanta energia oggi!'),
  _DailyWord('Risata', 'Laughter', '😂', 'La risata fa bene.'),
  _DailyWord('Passione', 'Passion', '🔥', 'La passione per imparare.'),
  _DailyWord('Natura', 'Nature', '🌿', 'La natura è bellissima.'),
  _DailyWord('Fantasia', 'Imagination', '🦄', 'Usa la tua fantasia!'),
  _DailyWord('Successo', 'Success', '🏆', 'Il successo viene con la pratica.'),
];

class WordOfTheDay extends StatelessWidget {
  const WordOfTheDay({super.key});

  _DailyWord _today() {
    final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _words[dayOfYear % _words.length];
  }

  @override
  Widget build(BuildContext context) {
    final _DailyWord word = _today();
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: <Widget>[
          Text(word.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Word of the Day', style: text.labelMedium?.copyWith(color: Colors.white70)),
                Text(word.italian, style: text.titleLarge?.copyWith(color: Colors.white)),
                Text(word.english, style: text.bodyMedium?.copyWith(color: Colors.white70)),
                Text('"${word.example}"',
                    style: text.bodyMedium?.copyWith(color: Colors.white, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => sl<TtsService>().speak('${word.italian}. ${word.example}'),
            icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
