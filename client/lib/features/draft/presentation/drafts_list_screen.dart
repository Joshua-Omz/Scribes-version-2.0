import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../compose/application/compose_provider.dart';
import '../application/drafts_list_provider.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_toast.dart';

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
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
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
                    child: HugeIcon(icon: HugeIcons.strokeRoundedFile01,
                      size: 140,
                      color: colors.gold.withValues(alpha: 0.05),
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
                        HugeIcon(icon: HugeIcons.strokeRoundedInbox, size: 48, color: colors.goldMuted.withValues(alpha: 0.5)),
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
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final draft = drafts[index];
                      String title = 'Untitled Draft';
                      String excerpt = 'No content';
                      if (draft.content.containsKey('title') && draft.content['title'].toString().trim().isNotEmpty) {
                        title = draft.content['title'];
                      }
                      if (draft.content.containsKey('excerpt') && draft.content['excerpt'].toString().trim().isNotEmpty) {
                        excerpt = draft.content['excerpt'];
                      }
                      return ScribesGridCard(
                        title: title,
                        excerpt: excerpt,
                        date: draft.updatedAt,
                        isDraft: true,
                        onTap: () {
                          ref.read(composeProvider.notifier).loadDraft(
                            draft.id,
                            draft.content,
                            caption: draft.caption,
                            sermonSource: draft.sermonSource,
                            categoryIds: draft.categoryIds,
                          );
                          context.push('/compose');
                        },
                        onDelete: () {
                          ref.read(draftsListProvider.notifier).deleteDraft(draft.id);
                          final colors = ref.read(themeProvider);
                          ScribesToast.show(context, 'Draft deleted', colors);
                        },
                      );
                    },
                    childCount: drafts.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ScribesShimmer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                  childCount: 6,
                ),
              ),
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
        heroTag: null,
        backgroundColor: colors.gold,
        foregroundColor: colors.surfaceRaised,
        elevation: 4,
        onPressed: () {
          ref.read(composeProvider.notifier).reset();
          context.push('/compose');
        },
        icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign),
        label: Text('New Draft', style: ScribesTextStyles.labelLg.copyWith(color: colors.surfaceRaised)),
      ),
    );
  }
}
