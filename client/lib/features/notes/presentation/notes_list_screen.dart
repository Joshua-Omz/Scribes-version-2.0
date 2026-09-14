import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../auth/application/auth_notifier.dart';
import '../../export/domain/exportable_document.dart';
import '../../export/presentation/export_loading_sheet.dart';
import '../../notes/domain/note.dart';
import '../application/notes_list_provider.dart';
import '../application/note_editor_provider.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  final Set<String> _selectedIds = {};
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notesListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
    final notesAsync = ref.watch(notesListProvider);
    final isSelectionMode = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: isSelectionMode
          ? _buildSelectionActions(colors)
          : FloatingActionButton(
              heroTag: 'add_note_fab',
              backgroundColor: colors.surfaceRaised,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colors.goldEdge, width: 1.2),
              ),
              onPressed: () {
                ref.read(noteEditorProvider.notifier).reset();
                context.push('/notes/edit');
              },
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedQuillWrite02,
                color: colors.gold,
                size: 24,
              ),
            ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 3),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: _isSearchActive ? null : 180.0,
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
                    title: Text(
                      isSelectionMode
                          ? '${_selectedIds.length} Selected'
                          : 'My Notes',
                      style: ScribesTextStyles.displayLg.copyWith(
                        color: colors.primaryText,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      color: colors.surface,
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFileEdit,
                          size: 80,
                          color: colors.border,
                        ),
                      ),
                    ),
                  ),
            title: _isSearchActive
                ? ScribesTextField(
                    hintText: 'Search notes...',
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
          notesAsync.when(
            data: (notes) {
              var filteredNotes = notes;
              if (_searchQuery.trim().isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                filteredNotes = notes.where((note) {
                  final title = note.title?.toLowerCase() ?? '';
                  String snippet = '';
                  try {
                    final body = note.content['body'];
                    if (body is List && body.isNotEmpty) {
                      final firstInsert = body.firstWhere(
                        (e) => e['insert'] is String,
                        orElse: () => null,
                      );
                      if (firstInsert != null) {
                        snippet = firstInsert['insert']
                            .toString()
                            .replaceAll('\n', ' ')
                            .trim()
                            .toLowerCase();
                      }
                    }
                  } catch (_) {}
                  return title.contains(q) || snippet.contains(q);
                }).toList();
              }

              if (filteredNotes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedFile01,
                          size: 64,
                          color: colors.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matches found.'
                              : 'No notes yet',
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term.'
                              : 'Jot down thoughts and ideas.',
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = filteredNotes[index];
                    String snippet = '';
                    try {
                      final body = note.content['body'];
                      if (body is List && body.isNotEmpty) {
                        final firstInsert = body.firstWhere(
                          (e) => e['insert'] is String,
                          orElse: () => null,
                        );
                        if (firstInsert != null) {
                          snippet = firstInsert['insert']
                              .toString()
                              .replaceAll('\n', ' ')
                              .trim();
                        }
                      }
                    } catch (_) {}

                    return ScribesGridCard(
                      title: note.title ?? '',
                      excerpt: snippet,
                      date: note.updatedAt,
                      isSelected: _selectedIds.contains(note.id),
                      onLongPress: () {
                        if (isSelectionMode) {
                          _toggleSelection(note.id);
                        } else {
                          _showNoteOptions(note, colors);
                        }
                      },
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(note.id);
                        } else {
                          ref
                              .read(noteEditorProvider.notifier)
                              .loadNote(
                                note.id,
                                note.content,
                                title: note.title,
                                notebookId: note.notebookId,
                              );
                          context.push('/notes/edit');
                        }
                      },
                    );
                  }, childCount: filteredNotes.length),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: colors.gold),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error loading notes: $err',
                  style: TextStyle(color: colors.primaryText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions(dynamic colors) {
    final notesAsync = ref.read(notesListProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'export_selected_notes',
          backgroundColor: colors.surfaceRaised,
          foregroundColor: colors.gold,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.goldEdge, width: 1.0),
          ),
          onPressed: () {
            final allNotes = notesAsync.value ?? [];
            final selectedNotes = allNotes
                .where((n) => _selectedIds.contains(n.id))
                .toList();
            if (selectedNotes.isEmpty) return;
            final user = ref.read(authProvider).value;
            final docs = selectedNotes
                .map((n) => NoteExportAdapter(n, currentUser: user))
                .toList();
            ExportLoadingSheet.showForCompendium(
              context,
              docs,
              title: 'Study Notes Compendium (${docs.length})',
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
          heroTag: 'delete_selected_notes',
          backgroundColor: Colors.red.shade400,
          foregroundColor: colors.surfaceRaised,
          elevation: 4,
          onPressed: () {
            for (final id in _selectedIds) {
              ref.read(notesListProvider.notifier).deleteNote(id);
            }
            final count = _selectedIds.length;
            setState(() {
              _selectedIds.clear();
            });
            ScribesToast.show(context, 'Deleted $count note(s)', colors);
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
    );
  }

  void _showNoteOptions(Note note, dynamic colors) {
    final user = ref.read(authProvider).value;

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
              title: Text(
                'Edit Note',
                style: TextStyle(color: colors.primaryText),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref
                    .read(noteEditorProvider.notifier)
                    .loadNote(
                      note.id,
                      note.content,
                      title: note.title,
                      notebookId: note.notebookId,
                    );
                context.push('/notes/edit');
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedFile02,
                color: colors.gold,
              ),
              title: Text(
                'Export Manuscript (PDF)',
                style: TextStyle(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ExportLoadingSheet.showForNote(
                  context,
                  note,
                  currentUser: user,
                );
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckList,
                color: colors.secondaryText,
              ),
              title: Text(
                'Select Item',
                style: TextStyle(color: colors.secondaryText),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelection(note.id);
              },
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: Colors.red.shade400,
              ),
              title: Text(
                'Delete Note',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(notesListProvider.notifier).deleteNote(note.id);
                ScribesToast.show(context, 'Note deleted', colors);
              },
            ),
          ],
        ),
      ),
    );
  }
}
