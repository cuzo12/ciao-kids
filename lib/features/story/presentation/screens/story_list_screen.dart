import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_stories.dart';

/// Lists available interactive stories.
class StoryListScreen extends StatefulWidget {
  /// Creates the [StoryListScreen].
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  List<Story>? _stories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<Story> stories = await sl<GetStories>()();
    if (mounted) setState(() => _stories = stories);
  }

  void _open(Story story) {
    context.pushNamed(
      Routes.storyName,
      pathParameters: <String, String>{'id': story.id},
      extra: story,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<Story>? stories = _stories;

    return Scaffold(
      appBar: AppBar(title: const Text('Story Mode')),
      body: SafeArea(
        child: stories == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: stories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final Story story = stories[index];
                  return Material(
                    color: AppColors.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: InkWell(
                      onTap: () => _open(story),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: <Widget>[
                            Text(story.emoji,
                                style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(story.title, style: text.titleLarge),
                                  const SizedBox(height: 2),
                                  Text(story.subtitle, style: text.bodyMedium),
                                ],
                              ),
                            ),
                            const Icon(Icons.auto_stories_rounded,
                                color: AppColors.secondary),
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
