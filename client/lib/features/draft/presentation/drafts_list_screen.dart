import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../auth/application/auth_notifier.dart';
import '../../compose/application/compose_provider.dart';
import '../../draft/domain/draft.dart';
import '../../export/domain/exportable_document.dart';
import '../../export/presentation/export_loading_sheet.dart';
import '../application/drafts_list_provider.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_glass_fab.dart';

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
              icon: HugeIcon(
                icon: isSelectionMode
                    ? HugeIcons.strokeRoundedCancel01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: colors.primaryText,
              ),
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
                      isSelectionMode
                          ? '${_selectedIds.length} Selected'
                          : 'Drafts Workspace',
                      style: ScribesTextStyles.displayLg.copyWith(
                        color: colors.primaryText,
                      ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    onChanged: (query) => setState(() => _searchQuery = query),
                  )
                : null,
            actions: [
              if (!_isSearchActive && !isSelectionMode)
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: colors.primaryText,
                  ),
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
                  final title = (d.content['title']?.toString() ?? '')
                      .toLowerCase();
                  final excerpt = (d.content['excerpt']?.toString() ?? '')
                      .toLowerCase();
                  return title.contains(q) || excerpt.contains(q);
                }).toList();
              }

              if (filteredDrafts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedInbox,
                          size: 48,
                          color: colors.goldMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matches found.'
                              : 'No drafts yet.',
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term.'
                              : 'Your works in progress will appear here.',
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText,
                          ),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final draft = filteredDrafts[index];
                    String title = 'Untitled Draft';
                    String excerpt = 'No content';
                    if (draft.content.containsKey('title') &&
                        draft.content['title'].toString().trim().isNotEmpty) {
                      title = draft.content['title'];
                    }
                    if (draft.content.containsKey('excerpt') &&
                        draft.content['excerpt'].toString().trim().isNotEmpty) {
                      excerpt = draft.content['excerpt'];
                    }
                    return ScribesGridCard(
                      title: title,
                      excerpt: excerpt,
                      date: draft.updatedAt,
                      isSelected: _selectedIds.contains(draft.id),
                      onLongPress: () {
                        if (isSelectionMode) {
                          _toggleSelection(draft.id);
                        } else {
                          _showDraftOptions(draft, colors);
                        }
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(draft.id);
                        } else {
                          ref
                              .read(composeProvider.notifier)
                              .loadDraft(
                                draft.id,
                                draft.content,
                                caption: draft.caption,
                                sermonSource: draft.sermonSource,
                              );
                          context.push('/compose');
                        }
                      },
                    );
                  }, childCount: filteredDrafts.length),
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  return ScribesShimmer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }, childCount: 6),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load drafts',
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.orange,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'export_selected_drafts',
                  backgroundColor: colors.surfaceRaised,
                  foregroundColor: colors.gold,
                  elevation: 4,
                  onPressed: () {
                    final allDrafts = draftsState.value ?? [];
                    final selectedDrafts = allDrafts
                        .where((d) =>
                            _selectedIds.contains(d.id) &&
                            d.postType == 'standard')
                        .toList();
                    if (selectedDrafts.isEmpty) {
                      ScribesToast.show(
                        context,
                        'Only standard drafts can be exported',
                        colors,
                      );
                      return;
                    }
                    final user = ref.read(authProvider).value;
                    final docs = selectedDrafts
                        .map((d) => DraftExportAdapter(d, currentUser: user))
                        .toList();
                    ExportLoadingSheet.showForCompendium(
                      context,
                      docs,
                      title: 'Drafts Collection (${docs.length})',
                    );
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFile02,
                    color: colors.gold,
                  ),
                  label: Text(
                    'Export (${_selectedIds.length})',
                    style: ScribesTextStyles.labelLg.copyWith(
                      color: colors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'delete_selected_drafts',
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: colors.surfaceRaised,
                  elevation: 4,
                  onPressed: () {
                    for (final id in _selectedIds) {
                      ref.read(draftsListProvider.notifier).deleteDraft(id);
                    }
                    final count = _selectedIds.length;
                    setState(() => _selectedIds.clear());
                    ScribesToast.show(
                      context,
                      'Deleted $count draft(s)',
                      colors,
                    );
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: colors.surfaceRaised,
                  ),
                  label: Text(
                    'Delete',
                    style: ScribesTextStyles.labelLg.copyWith(
                      color: colors.surfaceRaised,
                    ),
                  ),
                ),
              ],
            )
          : ScribesGlassFab(
              onTap: () {
                ref.read(composeProvider.notifier).reset();
                context.push('/compose');
              },
              icon: HugeIcons.strokeRoundedPlusSign,
            ),
    );
  }

  void _showDraftOptions(Draft draft, dynamic colors) {
    final user = ref.read(authProvider).value;
    final isStandard = draft.postType == 'standard';

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedQuillWrite02,
                color: colors.primaryText,
              ),
              title: Text('Edit Draft', style: TextStyle(color: colors.primaryText)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(composeProvider.notifier).loadDraft(
                      draft.id,
                      draft.content,
                      caption: draft.caption,
                      sermonSource: draft.sermonSource,
                    );
                context.push('/compose');
              },
            ),
            if (isStandard)
              ListTile(
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedFile02,
                  color: colors.gold,
                ),
                title: Text(
                  'Export Manuscript (PDF)',
                  style: TextStyle(color: colors.gold, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ExportLoadingSheet.showForDraft(
                    context,
                    draft,
                    currentUser: user,
                  );
                },
              ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckList,
                color: colors.secondaryText,
              ),
              title: Text('Select Item', style: TextStyle(color: colors.secondaryText)),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelection(draft.id);
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: Colors.red.shade400,
              ),
              title: Text(
                'Delete Draft',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(draftsListProvider.notifier).deleteDraft(draft.id);
                ScribesToast.show(context, 'Draft deleted', colors);
              },
            ),
          ],
        ),
      ),
    );
  }
}
