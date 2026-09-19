import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_quill_scripture_helper.dart';
import '../../../core/theme/scribes_quill_auto_number_rule.dart';
import '../../../core/widgets/scribes_auto_save_dot.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../../core/widgets/scribes_scripture_quick_dialog.dart';
import '../../../core/widgets/scribes_quill_toolbar.dart';
import '../../auth/application/auth_notifier.dart';
import '../../draft/domain/draft.dart';
import '../../export/presentation/export_loading_sheet.dart';
import '../../posts/domain/scripture_ref.dart';
import '../application/compose_provider.dart';

class DraftEditorScreen extends ConsumerStatefulWidget {
  const DraftEditorScreen({super.key});

  @override
  ConsumerState<DraftEditorScreen> createState() => _DraftEditorScreenState();
}

class _DraftEditorScreenState extends ConsumerState<DraftEditorScreen> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _titleController;
  String? _activeInlineScripture;

  @override
  void initState() {
    super.initState();
    final state = ref.read(composeProvider);
    _titleController = TextEditingController(text: state.title);

    Document doc;
    if (state.contentDelta != null && state.contentDelta!.isNotEmpty) {
      try {
        doc = Document.fromJson(state.contentDelta!);
      } catch (err) {
        debugPrint(
          '[DraftEditor] Invalid delta: $err. Falling back to basic document.',
        );
        doc = Document();
      }
    } else {
      doc = Document();
    }

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
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
    ref.read(composeProvider.notifier).onDocumentChanged(_controller);
    final active = ScribesQuillScriptureHelper.getActiveScriptureReference(
      _controller,
    );
    if (active != _activeInlineScripture) {
      setState(() {
        _activeInlineScripture = active;
      });
    }
  }

  void _openScriptureSelector() {
    final colors = ref.read(themeProvider);
    ScribesScriptureSelector.show(
      context,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        if (chapter != null && verseStart != null) {
          final refObj = ScriptureRef(
            book: book,
            chapter: chapter,
            verseStart: verseStart,
            verseEnd: verseEnd,
          );
          ref.read(composeProvider.notifier).addScriptureRef(refObj);
        }
      },
    );
  }

  void _showScriptureQuickDialog(ScriptureRef refObj) {
    final colors = ref.read(themeProvider);
    String reference = '${refObj.book} ${refObj.chapter}:${refObj.verseStart}';
    if (refObj.verseEnd != null && refObj.verseEnd != refObj.verseStart) {
      reference += '-${refObj.verseEnd}';
    }

    ScribesScriptureQuickDialog.show(
      context,
      reference: reference,
      onRemove: () {
        ref.read(composeProvider.notifier).removeScriptureRef(refObj);
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
          'Inserted $reference into draft',
          colors,
          icon: HugeIcons.strokeRoundedBookOpen01,
        );
      },
    );
  }

  void _showInlineScriptureDialog(String reference) {
    ScribesScriptureQuickDialog.show(
      context,
      reference: reference,
      onRemove: () {
        ScribesQuillScriptureHelper.removeScriptureAttribute(_controller);
        setState(() => _activeInlineScripture = null);
      },
      onInsertIntoNote: (verseText) {
        final index = _controller.selection.baseOffset >= 0
            ? _controller.selection.baseOffset
            : _controller.document.length - 1;
        _controller.document.insert(
          index,
          '\n"$verseText" — $reference (BSB)\n',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final composeState = ref.watch(composeProvider);

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
            await ref.read(composeProvider.notifier).forceSave();
            if (context.mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/posts');
              }
            }
          },
        ),
        title: Text(
          'Compose',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(composeProvider);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isSaving || state.lastSavedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ScribesAutoSaveDot(
                        state: state.isSaving
                            ? SaveState.saving
                            : SaveState.localSaved,
                      ),
                    ),
                  if (state.postType == 'standard')
                    IconButton(
                      tooltip: 'Export Manuscript (PDF)',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedPrinter,
                        color: colors.gold,
                        size: 20,
                      ),
                      onPressed: () {
                        final composeState = ref.read(composeProvider);
                        final user = ref.read(authProvider).value;
                        final draftDoc = Draft(
                          id: composeState.draftId,
                          authorId: user?.id ?? 'guest',
                          content: {
                            'title': _titleController.text.trim(),
                            'body': _controller.document.toDelta().toJson(),
                            'excerpt': composeState.caption,
                          },
                          caption: composeState.caption,
                          sermonSource: composeState.sermonSource,
                          scriptureTags: composeState.scriptureRefs
                              .map((r) =>
                                  '${r.book} ${r.chapter}:${r.verseStart}${r.verseEnd != null && r.verseEnd != r.verseStart ? "-${r.verseEnd}" : ""}')
                              .toList(),
                          postType: composeState.postType,
                          coverImageUrl: composeState.coverImageUrl,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        ExportLoadingSheet.showForDraft(
                          context,
                          draftDoc,
                          currentUser: user,
                        );
                      },
                    ),
                  TextButton(
                    onPressed: () async {
                      await ref.read(composeProvider.notifier).forceSave();
                      if (context.mounted) {
                        context.push('/compose/preview');
                      }
                    },
                    child: Text(
                      'Next',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.bold,
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
                      hintText: 'Title...',
                      hintStyle: ScribesTextStyles.displayLg.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      ref.read(composeProvider.notifier).updateTitle(val);
                    },
                  ),
                  const SizedBox(height: 8),
                  // Scripture Tag Bar (Single-row horizontal ribbon)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
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
                        if (composeState.scriptureRefs.isNotEmpty)
                          const SizedBox(width: 8),
                        ...composeState.scriptureRefs.map((refObj) {
                          String refStr =
                              '${refObj.book} ${refObj.chapter}:${refObj.verseStart}';
                          if (refObj.verseEnd != null &&
                              refObj.verseEnd != refObj.verseStart) {
                            refStr += '-${refObj.verseEnd}';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => _showScriptureQuickDialog(refObj),
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
                                    color: colors.goldMuted
                                        .withValues(alpha: 0.6),
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
                                          .read(composeProvider.notifier)
                                          .removeScriptureRef(refObj),
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
                          );
                        }),
                      ],
                    ),
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
                              onTap: () => _showInlineScriptureDialog(
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
                        spaceShortcutEvents: standardSpaceShorcutEvents,
                        characterShortcutEvents: standardCharactersShortcutEvents,
                        onKeyPressed: (event, node) => handleAutoNumberOnEnter(event, _controller),
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
          ScribesQuillToolbar(
            controller: _controller,
            onTagScripture: _handleToolbarTagScripture,
            colors: colors,
          ),
        ],
      ),
    );
  }

  void _handleToolbarTagScripture() {
    final colors = ref.read(themeProvider);
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
          if (chapter != null && verseStart != null) {
            ref
                .read(composeProvider.notifier)
                .addScriptureRef(
                  ScriptureRef(
                    book: book,
                    chapter: chapter,
                    verseStart: verseStart,
                    verseEnd: verseEnd,
                  ),
                );
          }
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
          if (chapter != null && verseStart != null) {
            ref
                .read(composeProvider.notifier)
                .addScriptureRef(
                  ScriptureRef(
                    book: book,
                    chapter: chapter,
                    verseStart: verseStart,
                    verseEnd: verseEnd,
                  ),
                );
          }
          ScribesToast.show(
            context,
            'Inserted Scripture: $refStr',
            colors,
            icon: HugeIcons.strokeRoundedBookOpen01,
          );
        },
      );
    }
  }
}
