import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/scribes_toast.dart';
import '../../data/bible_repository.dart';

/// A bottom sheet for creating or editing a note attached to a specific verse.
///
/// Opens from the BibleSelectionActionBar when the user taps "Note".
/// Content is stored as plain text in v1 (Quill Delta upgrade deferred
/// until the rich-text editor is standardised across notes/drafts/posts).
class VerseNoteEditorSheet extends ConsumerStatefulWidget {
  final String bookCode;
  final int chapter;
  final int verse;
  final String verseText;
  final String displayLabel; // e.g. "Genesis 1:1"
  final String? existingNoteId;
  final String? existingContent;

  const VerseNoteEditorSheet({
    super.key,
    required this.bookCode,
    required this.chapter,
    required this.verse,
    required this.verseText,
    required this.displayLabel,
    this.existingNoteId,
    this.existingContent,
  });

  @override
  ConsumerState<VerseNoteEditorSheet> createState() =>
      _VerseNoteEditorSheetState();
}

class _VerseNoteEditorSheetState extends ConsumerState<VerseNoteEditorSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _resolveInitialText());
  }

  String _resolveInitialText() {
    if (widget.existingContent == null || widget.existingContent!.isEmpty) {
      return '';
    }
    // If content is a JSON Quill delta, try to extract plain text
    try {
      final decoded = jsonDecode(widget.existingContent!);
      if (decoded is List) {
        // Quill delta ops — extract insert strings
        return decoded
            .where((op) => op is Map && op['insert'] is String)
            .map((op) => op['insert'] as String)
            .join();
      }
    } catch (_) {}
    // Fallback: treat as plain text
    return widget.existingContent!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(bibleRepositoryProvider);

      // Store as simple Quill delta JSON for forward compatibility
      final deltaJson = jsonEncode([
        {'insert': '$text\n'}
      ]);

      await repo.saveVerseNote(
        bookCode: widget.bookCode,
        chapter: widget.chapter,
        verse: widget.verse,
        content: deltaJson,
        plainPreview: text.length > 120 ? '${text.substring(0, 120)}…' : text,
        existingId: widget.existingNoteId,
      );

      if (mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(
          context,
          widget.existingNoteId != null ? 'Note updated' : 'Note saved',
          colors,
          icon: HugeIcons.strokeRoundedNotebook,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(context, 'Failed to save note', colors);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.existingNoteId == null) return;

    final repo = ref.read(bibleRepositoryProvider);
    await repo.deleteVerseNote(widget.existingNoteId!);

    if (mounted) {
      final colors = ref.read(themeProvider);
      ScribesToast.show(
        context,
        'Note deleted',
        colors,
        icon: HugeIcons.strokeRoundedDelete02,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final isEditing = widget.existingNoteId != null;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: bottomInset > 0
              ? (screenHeight - bottomInset) * 0.92
              : screenHeight * 0.75,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ScribesRadius.sheet),
          ),
          border: Border(
            top: BorderSide(
              color: colors.border.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pill Handle ──
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotebook,
                        color: colors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Note' : 'Write Note',
                            style: ScribesTextStyles.displayMd.copyWith(
                              color: colors.primaryText,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            widget.displayLabel,
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEditing)
                      IconButton(
                        onPressed: _delete,
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: colors.secondaryText,
                          size: 18,
                        ),
                        tooltip: 'Delete note',
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Scrollable Content Area: Verse Quote + TextField ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.verseText.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(ScribesRadius.card),
                            border: Border.all(
                              color: colors.gold.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            widget.verseText,
                            style: ScribesTextStyles.bodyMd.copyWith(
                              color: colors.primaryText.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            maxLines: bottomInset > 0 ? 2 : 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 3,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.primaryText,
                          height: 1.65,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts on this verse…',
                          hintStyle: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Pinned Save Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.background,
                      disabledBackgroundColor: colors.gold.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.background,
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Note' : 'Save Note',
                            style: ScribesTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.background,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
