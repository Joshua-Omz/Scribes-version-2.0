import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_quill_scripture_helper.dart';
import '../../../core/widgets/scribes_auto_save_dot.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../../core/widgets/scribes_scripture_quick_dialog.dart';
import '../application/note_editor_provider.dart';
import '../../compose/application/compose_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _titleController;
  String? _activeInlineScripture;

  @override
  void initState() {
    super.initState();
    final state = ref.read(noteEditorProvider);
    _titleController = TextEditingController(text: state.title);

    if (state.contentDelta != null) {
      final doc = Document.fromJson(state.contentDelta!);
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
    _controller.addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    ref.read(noteEditorProvider.notifier).onDocumentChanged(_controller);
    final active = ScribesQuillScriptureHelper.getActiveScriptureReference(
      _controller,
    );
    if (active != _activeInlineScripture) {
      setState(() {
        _activeInlineScripture = active;
      });
    }
  }

  Future<void> _promoteToDraft() async {
    final colors = ref.read(themeProvider);

    try {
      final draftId = await ref
          .read(noteEditorProvider.notifier)
          .promoteToDraft();
      final noteState = ref.read(noteEditorProvider);
      ref.read(composeProvider.notifier).reset();

      final draftNotifier = ref.read(composeProvider.notifier);
      draftNotifier.updateTitle(noteState.title);
      draftNotifier.loadDraft(draftId, {
        'title': noteState.title,
        'body': noteState.contentDelta,
        'scripture_refs': noteState.scriptureRefs,
      });

      if (mounted) {
        ScribesToast.show(context, 'Note copied to drafts!', colors);
        context.go('/compose');
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(
          context,
          'Failed to copy to drafts. Please try again.',
          colors,
          isError: true,
        );
      }
    }
  }

  void _openScriptureSelector() {
    final colors = ref.read(themeProvider);
    ScribesScriptureSelector.show(
      context,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        String refStr = book;
        if (chapter != null) {
          refStr += ' $chapter';
          if (verseStart != null) {
            refStr += ':$verseStart';
            if (verseEnd != null && verseEnd != verseStart) {
              refStr += '-$verseEnd';
            }
          }
        }
        ref.read(noteEditorProvider.notifier).addScripture(refStr);
      },
    );
  }

  void _showScriptureQuickDialog(String reference) {
    final colors = ref.read(themeProvider);

    ScribesScriptureQuickDialog.show(
      context,
      reference: reference,
      onRemove: () {
        ref.read(noteEditorProvider.notifier).removeScripture(reference);
        // Also remove inline highlight if currently selected
        if (_activeInlineScripture == reference) {
          ScribesQuillScriptureHelper.removeScriptureAttribute(_controller);
          setState(() => _activeInlineScripture = null);
        }
      },
      onInsertIntoNote: (verseText) {
        final index = _controller.selection.baseOffset >= 0
            ? _controller.selection.baseOffset
            : _controller.document.length - 1;
        _controller.document.insert(
          index,
          '\n"$verseText" — $reference (BSB)\n',
        );
        ScribesToast.show(
          context,
          'Inserted $reference into note',
          colors,
          icon: HugeIcons.strokeRoundedBookOpen01,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final noteState = ref.watch(noteEditorProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.primaryText,
          ),
          onPressed: () async {
            await ref.read(noteEditorProvider.notifier).forceSave();
            if (context.mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/notes');
              }
            }
          },
        ),
        title: Text(
          'Notes',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final composeState = ref.watch(noteEditorProvider);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (composeState.isSaving || composeState.lastSavedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ScribesAutoSaveDot(
                        state: composeState.isSaving
                            ? SaveState.saving
                            : SaveState.localSaved,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _promoteToDraft,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedFileExport,
                      color: colors.orange,
                      size: 18,
                    ),
                    label: Text(
                      'Copy to Drafts',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: ScribesTextStyles.displayLg.copyWith(
                      color: colors.primaryText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note Title...',
                      hintStyle: ScribesTextStyles.displayLg.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      ref.read(noteEditorProvider.notifier).updateTitle(val);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Scripture Tag Bar
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...noteState.scriptureRefs.map(
                        (refStr) => InkWell(
                          onTap: () => _showScriptureQuickDialog(refStr),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colors.goldMuted.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookOpen01,
                                  size: 13,
                                  color: colors.gold,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  refStr,
                                  style: ScribesTextStyles.labelSm.copyWith(
                                    color: colors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => ref
                                      .read(noteEditorProvider.notifier)
                                      .removeScripture(refStr),
                                  child: Icon(
                                    Icons.close,
                                    size: 13,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _openScriptureSelector,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colors.goldMuted.withValues(alpha: 0.4),
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14, color: colors.gold),
                              const SizedBox(width: 4),
                              Text(
                                'Tag Scripture',
                                style: ScribesTextStyles.labelSm.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Cursor-Aware Scripture Inspector Pill
                  if (_activeInlineScripture != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colors.goldMuted.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            size: 15,
                            color: colors.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => _showScriptureQuickDialog(
                                _activeInlineScripture!,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _activeInlineScripture!,
                                    style: ScribesTextStyles.labelSm.copyWith(
                                      color: colors.gold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• Tap to preview verse',
                                    style: ScribesTextStyles.caption.copyWith(
                                      color: colors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ScribesQuillScriptureHelper.removeScriptureAttribute(
                                _controller,
                              );
                              setState(() => _activeInlineScripture = null);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: colors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 4),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: QuillEditorConfig(
                        customStyleBuilder: (Attribute attribute) {
                          if (attribute.key == 'scripture') {
                            return ScribesQuillScriptureHelper
                                .buildScriptureTextStyle(colors);
                          }
                          return const TextStyle();
                        },
                        customStyles: DefaultStyles(
                          paragraph: DefaultTextBlockStyle(
                            ScribesTextStyles.bodyLg.copyWith(
                              color: colors.primaryText,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(16, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                          h1: DefaultTextBlockStyle(
                            ScribesTextStyles.displayLg.copyWith(
                              color: colors.primaryText,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(32, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                          h2: DefaultTextBlockStyle(
                            ScribesTextStyles.displayMd.copyWith(
                              color: colors.primaryText,
                            ),
                            const HorizontalSpacing(0, 0),
                            const VerticalSpacing(24, 0),
                            const VerticalSpacing(0, 0),
                            null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              showDividers:true,
              multiRowsDisplay: false,
              color: colors.surfaceRaised,
              showAlignmentButtons: false,
              showFontFamily: false,
              showFontSize: false,
              showBackgroundColorButton: false,
              showColorButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showClearFormat: false,
              customButtons: [
                QuillToolbarCustomButtonOptions(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    size: 18,
                    color: colors.gold,
                  ),
                  tooltip: 'Tag as Scripture',
                  onPressed: () {
                    final selection = _controller.selection;
                    if (!selection.isCollapsed) {
                      ScribesScriptureSelector.show(
                        context,
                        colors: colors,
                        onSelected: (book, chapter, verseStart, verseEnd) {
                          String refStr = book;
                          if (chapter != null) {
                            refStr += ' $chapter';
                            if (verseStart != null) {
                              refStr += ':$verseStart';
                              if (verseEnd != null && verseEnd != verseStart) {
                                refStr += '-$verseEnd';
                              }
                            }
                          }
                          ScribesQuillScriptureHelper.applyScriptureAttribute(
                            _controller,
                            refStr,
                          );
                          ref
                              .read(noteEditorProvider.notifier)
                              .addScripture(refStr);
                          ScribesToast.show(
                            context,
                            'Tagged as Scripture: $refStr',
                            colors,
                            icon: HugeIcons.strokeRoundedBookOpen01,
                          );
                        },
                      );
                    } else {
                      ScribesScriptureSelector.show(
                        context,
                        colors: colors,
                        onSelected: (book, chapter, verseStart, verseEnd) {
                          String refStr = book;
                          if (chapter != null) {
                            refStr += ' $chapter';
                            if (verseStart != null) {
                              refStr += ':$verseStart';
                              if (verseEnd != null && verseEnd != verseStart) {
                                refStr += '-$verseEnd';
                              }
                            }
                          }
                          final offset = _controller.selection.baseOffset >= 0
                              ? _controller.selection.baseOffset
                              : _controller.document.length - 1;
                          _controller.document.insert(offset, refStr);
                          _controller.updateSelection(
                            TextSelection(
                              baseOffset: offset,
                              extentOffset: offset + refStr.length,
                            ),
                            ChangeSource.local,
                          );
                          ScribesQuillScriptureHelper.applyScriptureAttribute(
                            _controller,
                            refStr,
                          );
                          _controller.updateSelection(
                            TextSelection.collapsed(
                              offset: offset + refStr.length,
                            ),
                            ChangeSource.local,
                          );
                          ref
                              .read(noteEditorProvider.notifier)
                              .addScripture(refStr);
                          ScribesToast.show(
                            context,
                            'Inserted Scripture: $refStr',
                            colors,
                            icon: HugeIcons.strokeRoundedBookOpen01,
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
