import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../compose/application/compose_provider.dart';
import '../application/drafts_list_provider.dart';
import 'widgets/scribes_draft_card.dart';

class DraftsListScreen extends ConsumerStatefulWidget {
  const DraftsListScreen({super.key});

  @override
  ConsumerState<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends ConsumerState<DraftsListScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure we don't modify state during build
    Future.microtask(() {
      ref.read(draftsListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final draftsState = ref.watch(draftsListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primaryText),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Drafts Workspace',
                style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
              ),
              background: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      Icons.edit_document,
                      size: 140,
                      color: colors.gold.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          draftsState.when(
            data: (drafts) {
              if (drafts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: colors.goldMuted.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No drafts yet.',
                          style: ScribesTextStyles.displayMd.copyWith(color: colors.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your works in progress will appear here.',
                          style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final draft = drafts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ScribesDraftCard(
                          draft: draft,
                          onTap: () {
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
                        ),
                      );
                    },
                    childCount: drafts.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(child: ScribesLoadingIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load drafts',
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.orange),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.gold,
        foregroundColor: colors.surfaceRaised,
        elevation: 4,
        onPressed: () {
          ref.read(composeProvider.notifier).reset();
          context.push('/compose');
        },
        icon: const Icon(Icons.add),
        label: Text('New Draft', style: ScribesTextStyles.labelLg.copyWith(color: colors.surfaceRaised)),
      ),
    );
  }
}
