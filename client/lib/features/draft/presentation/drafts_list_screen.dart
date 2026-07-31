import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../compose/application/compose_provider.dart';
import '../application/drafts_list_provider.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_text_field.dart';

class DraftsListScreen extends ConsumerStatefulWidget {
  const DraftsListScreen({super.key});

  @override
  ConsumerState<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends ConsumerState<DraftsListScreen> {
  final Set<String> _selectedIds = {};
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(draftsListProvider.notifier).refresh();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final draftsState = ref.watch(draftsListProvider);
    final isSelectionMode = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: colors.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: _isSearchActive ? null : 120,
            centerTitle: !_isSearchActive,
            leading: IconButton(
              icon: HugeIcon(icon: isSelectionMode ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
              onPressed: () {
                if (isSelectionMode) {
                  setState(() => _selectedIds.clear());
                } else if (_isSearchActive) {
                  setState(() {
                    _isSearchActive = false;
                    _searchQuery = '';
                  });
                } else if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
            flexibleSpace: _isSearchActive
                ? null
                : FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Text(
                      isSelectionMode ? '${_selectedIds.length} Selected' : 'Drafts Workspace',
                      style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                    ),
                    background: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedFile01,
                            size: 140,
                            color: colors.gold.withValues(alpha: 0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
            title: _isSearchActive
                ? ScribesTextField(
                    hintText: 'Search drafts...',
                    autofocus: true,
                    isSearchPill: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    onChanged: (query) => setState(() => _searchQuery = query),
                  )
                : null,
            actions: [
              if (!_isSearchActive && !isSelectionMode)
                IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: colors.primaryText),
                  onPressed: () => setState(() => _isSearchActive = true),
                ),
              const SizedBox(width: 8),
            ],
          ),
          draftsState.when(
            data: (drafts) {
              var filteredDrafts = drafts;
              if (_searchQuery.trim().isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                filteredDrafts = drafts.where((d) {
                  final title = (d.content['title']?.toString() ?? '').toLowerCase();
                  final excerpt = (d.content['excerpt']?.toString() ?? '').toLowerCase();
                  return title.contains(q) || excerpt.contains(q);
                }).toList();
              }

              if (filteredDrafts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedInbox, size: 48, color: colors.goldMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matches found.' : 'No drafts yet.',
                          style: ScribesTextStyles.displayMd.copyWith(color: colors.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty ? 'Try a different search term.' : 'Your works in progress will appear here.',
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
                      final draft = filteredDrafts[index];
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
                        isSelected: _selectedIds.contains(draft.id),
                        onLongPress: () => _toggleSelection(draft.id),
                        onTap: () {
                          if (isSelectionMode) {
                            _toggleSelection(draft.id);
                          } else {
                            ref.read(composeProvider.notifier).loadDraft(
                              draft.id,
                              draft.content,
                              caption: draft.caption,
                              sermonSource: draft.sermonSource,
                            );
                            context.push('/compose');
                          }
                        },
                      );
                    },
                    childCount: filteredDrafts.length,
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
      floatingActionButton: isSelectionMode
          ? FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.red.shade400,
              foregroundColor: colors.surfaceRaised,
              elevation: 4,
              onPressed: () {
                for (final id in _selectedIds) {
                  ref.read(draftsListProvider.notifier).deleteDraft(id);
                }
                final count = _selectedIds.length;
                setState(() => _selectedIds.clear());
                ScribesToast.show(context, 'Deleted $count draft(s)', colors);
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: colors.surfaceRaised),
              label: Text('Delete', style: ScribesTextStyles.labelLg.copyWith(color: colors.surfaceRaised)),
            )
          : FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: colors.gold,
              foregroundColor: colors.surfaceRaised,
              elevation: 4,
              onPressed: () {
                ref.read(composeProvider.notifier).reset();
                context.push('/compose');
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: colors.surfaceRaised),
              label: Text('New Draft', style: ScribesTextStyles.labelLg.copyWith(color: colors.surfaceRaised)),
            ),
    );
  }
}
