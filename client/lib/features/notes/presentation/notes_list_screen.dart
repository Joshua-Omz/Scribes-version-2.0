import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_drawer.dart';
import '../application/notes_list_provider.dart';
import '../application/note_editor_provider.dart';
import 'widgets/scribes_note_card.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notesListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      drawer: const ScribesDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: colors.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.primaryText),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Notes',
                style: ScribesTextStyles.displayLg.copyWith(
                  color: colors.primaryText,
                ),
              ),
              centerTitle: true,
              background: Container(
                color: colors.surface,
                child: Center(
                  child: Icon(
                    Icons.edit_note,
                    size: 80,
                    color: colors.border,
                  ),
                ),
              ),
            ),
          ),
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_document, size: 64, color: colors.border),
                        const SizedBox(height: 16),
                        Text(
                          'No notes yet',
                          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jot down thoughts and ideas.',
                          style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ScribesNoteCard(
                          note: note,
                          onTap: () {
                            ref.read(noteEditorProvider.notifier).loadNote(note.id, note.content, title: note.title, notebookId: note.notebookId);
                            context.push('/notes/edit');
                          },
                          onDelete: () {
                            ref.read(notesListProvider.notifier).deleteNote(note.id);
                          },
                        ),
                      );
                    },
                    childCount: notes.length,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.gold,
        child: Icon(Icons.add, color: colors.surfaceRaised),
        onPressed: () {
          ref.read(noteEditorProvider.notifier).reset();
          context.push('/notes/edit');
        },
      ),
    );
  }
}
