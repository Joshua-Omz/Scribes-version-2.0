import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../application/notes_list_provider.dart';
import '../application/note_editor_provider.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_text_field.dart';

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
                    title: Text(
                      isSelectionMode ? '${_selectedIds.length} Selected' : 'My Notes',
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
                      final firstInsert = body.firstWhere((e) => e['insert'] is String, orElse: () => null);
                      if (firstInsert != null) {
                        snippet = firstInsert['insert'].toString().replaceAll('\n', ' ').trim().toLowerCase();
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
                        HugeIcon(icon: HugeIcons.strokeRoundedFile01, size: 64, color: colors.border),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matches found.' : 'No notes yet',
                          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty ? 'Try a different search term.' : 'Jot down thoughts and ideas.',
                          style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = filteredNotes[index];
                      String snippet = '';
                      try {
                        final body = note.content['body'];
                        if (body is List && body.isNotEmpty) {
                          final firstInsert = body.firstWhere((e) => e['insert'] is String, orElse: () => null);
                          if (firstInsert != null) {
                            snippet = firstInsert['insert'].toString().replaceAll('\n', ' ').trim();
                          }
                        }
                      } catch (_) {}
                      
                      return ScribesGridCard(
                        title: note.title ?? '',
                        excerpt: snippet,
                        date: note.updatedAt,
                        isSelected: _selectedIds.contains(note.id),
                        onLongPress: () => _toggleSelection(note.id),
                        onTap: () {
                          if (isSelectionMode) {
                            _toggleSelection(note.id);
                          } else {
                            ref.read(noteEditorProvider.notifier).loadNote(note.id, note.content, title: note.title, notebookId: note.notebookId);
                            context.push('/notes/edit');
                          }
                        },
                      );
                    },
                    childCount: filteredNotes.length,
                  ),
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
                child: Text('Error loading notes: $err', style: TextStyle(color: colors.primaryText)),
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
              onPressed: () {
                for (final id in _selectedIds) {
                  ref.read(notesListProvider.notifier).deleteNote(id);
                }
                final count = _selectedIds.length;
                setState(() => _selectedIds.clear());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted $count note(s)')),
                );
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: colors.surfaceRaised),
              label: Text('Delete', style: ScribesTextStyles.labelLg.copyWith(color: colors.surfaceRaised)),
            )
          : FloatingActionButton(
              heroTag: null,
              backgroundColor: colors.gold,
              child: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, color: colors.surfaceRaised),
              onPressed: () {
                ref.read(noteEditorProvider.notifier).reset();
                context.push('/notes/edit');
              },
            ),
    );
  }
}
