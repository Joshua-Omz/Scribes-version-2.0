import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../compose/application/compose_provider.dart';
import '../application/drafts_list_provider.dart';
import 'widgets/scribes_draft_card.dart';

class DraftsListScreen extends ConsumerWidget {
  const DraftsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final draftsState = ref.watch(draftsListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        title: Text(
          'Drafts Workspace',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: colors.background,
        child: draftsState.when(
          data: (drafts) {
            if (drafts.isEmpty) {
              return Center(
                child: Text(
                  'Nothing written yet.',
                  style: ScribesTextStyles.displayMd.copyWith(color: colors.secondaryText),
                ),
              );
            }

            return RefreshIndicator(
              color: colors.gold,
              backgroundColor: colors.surfaceRaised,
              onRefresh: () => ref.read(draftsListProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: drafts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  return ScribesDraftCard(
                    draft: draft,
                    onTap: () {
                      // Load draft into compose provider
                      ref.read(composeProvider.notifier).loadDraft(
                        draft.id,
                        draft.content,
                        caption: draft.caption,
                        sermonSource: draft.sermonSource,
                      );
                      context.push('/compose');
                    },
                    onDelete: () {
                      ref.read(draftsListProvider.notifier).deleteDraft(draft.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Draft deleted')),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => Center(child: ScribesLoadingIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'Failed to load drafts',
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.orange),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.gold,
        foregroundColor: colors.surfaceRaised,
        onPressed: () {
          ref.read(composeProvider.notifier).reset();
          context.push('/compose');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
