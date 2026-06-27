import 'package:flutter/material.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/services/speech/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/phrasebook_data.dart';

/// A travel phrasebook: real phrases grouped by situation, tap any to hear it.
class PhrasebookScreen extends StatelessWidget {
  const PhrasebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Travel Phrasebook')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text('Real phrases for your trip — tap 🔊 to hear them.',
                  style: text.bodyLarge),
            ),
            for (final PhraseCategory cat in Phrasebook.categories)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ExpansionTile(
                  leading: Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                  title: Text(cat.title, style: text.titleMedium),
                  childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  children: <Widget>[
                    for (final Phrase p in cat.phrases)
                      ListTile(
                        title: Text(p.it, style: text.titleMedium),
                        subtitle: Text(p.en),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.tertiary),
                          onPressed: () => sl<TtsService>().speak(p.it),
                        ),
                        onTap: () => sl<TtsService>().speak(p.it),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
