import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/conversation_script.dart';
import '../../domain/usecases/get_conversations.dart';

/// Lists the available conversations and lets the child pick one to start.
class ConversationListScreen extends StatefulWidget {
  /// Creates the [ConversationListScreen].
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List<ConversationScript>? _scripts;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<ConversationScript> scripts = await sl<GetConversations>()();
    if (mounted) setState(() => _scripts = scripts);
  }

  void _open(ConversationScript script) {
    context.pushNamed(
      Routes.conversationName,
      pathParameters: <String, String>{'id': script.id},
      extra: script,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<ConversationScript>? scripts = _scripts;

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Talking')),
      body: SafeArea(
        child: scripts == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: scripts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final ConversationScript script = scripts[index];
                  return Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: InkWell(
                      onTap: () => _open(script),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: <Widget>[
                            Text(script.characterEmoji,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(script.title, style: text.titleLarge),
                                  const SizedBox(height: 2),
                                  Text(script.subtitle, style: text.bodyMedium),
                                  Text('with ${script.characterName}',
                                      style: text.labelMedium),
                                ],
                              ),
                            ),
                            const Icon(Icons.chat_bubble_rounded,
                                color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
