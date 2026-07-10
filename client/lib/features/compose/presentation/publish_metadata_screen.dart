import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../posts/domain/sermon_source.dart';
import '../application/compose_provider.dart';

class PublishMetadataScreen extends ConsumerWidget {
  const PublishMetadataScreen({super.key});

  void _showPublishConfirmation(BuildContext context, WidgetRef ref) {
    final colors = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Publish Post?',
                style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 16),
              Text(
                'Publishing creates a public post that cannot be erased. It will be permanently added to your scroll and visible to your followers.',
                textAlign: TextAlign.center,
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Not yet', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surfaceRaised,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(composeProvider.notifier).publishToCloud().then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post published!')),
                          );
                          context.go('/feed');
                        }
                      }).catchError((err) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error publishing: $err')),
                          );
                        }
                      });
                    },
                    child: const Text('Publish'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final composeState = ref.watch(composeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () {
            context.pop(); // Go back to Preview
          },
        ),
        title: Text(
          'Post Details',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (composeState.title.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add a title before publishing.')),
                );
                return;
              }
              if (composeState.contentDelta == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post body cannot be empty.')),
                );
                return;
              }
              _showPublishConfirmation(context, ref);
            },
            child: Text(
              'Publish',
              style: ScribesTextStyles.labelLg.copyWith(color: colors.orange),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: colors.background,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Context is everything.',
                style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 8),
              Text(
                'Add optional metadata to help others discover your post.',
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
              ),
              const SizedBox(height: 32),
              TextFormField(
                initialValue: composeState.caption,
                style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: 'Caption (Optional)',
                  labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.gold),
                  ),
                ),
                onChanged: (value) => ref.read(composeProvider.notifier).updateMetadata(caption: value),
              ),
              const SizedBox(height: 32),
              Text(
                'Sermon Details',
                style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: composeState.sermonSource?.preacher,
                style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Preacher',
                  labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.gold)),
                ),
                onChanged: (value) {
                  final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                  ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(preacher: value));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: composeState.sermonSource?.church,
                style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Church',
                  labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.gold)),
                ),
                onChanged: (value) {
                  final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                  ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(church: value));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: composeState.sermonSource?.series,
                style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                decoration: InputDecoration(
                  labelText: 'Sermon Series',
                  labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.gold)),
                ),
                onChanged: (value) {
                  final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                  ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(series: value));
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                    ref.read(composeProvider.notifier).updateMetadata(
                      sermonSource: src.copyWith(date: date.toIso8601String().split('T')[0]),
                    );
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colors.border)),
                  ),
                  child: Text(
                    composeState.sermonSource?.date ?? 'Select Date',
                    style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
