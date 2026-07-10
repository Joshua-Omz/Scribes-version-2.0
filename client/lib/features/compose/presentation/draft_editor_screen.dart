import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_auto_save_dot.dart';
import '../application/compose_provider.dart';

class DraftEditorScreen extends ConsumerStatefulWidget {
  const DraftEditorScreen({super.key});

  @override
  ConsumerState<DraftEditorScreen> createState() => _DraftEditorScreenState();
}

class _DraftEditorScreenState extends ConsumerState<DraftEditorScreen> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(composeProvider);
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
    super.dispose();
  }

  void _onDocumentChanged() {
    ref.read(composeProvider.notifier).onDocumentChanged(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/drafts');
            }
          },
        ),
        title: Text(
          'Writing Studio',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final composeState = ref.watch(composeProvider);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (composeState.isSaving || composeState.lastSavedAt != null)
                    ScribesAutoSaveDot(
                      state: composeState.isSaving ? SaveState.saving : SaveState.localSaved,
                    ),
                  TextButton(
                    onPressed: () async {
                      await ref.read(composeProvider.notifier).forceSave();
                      if (context.mounted) {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/drafts');
                        }
                      }
                    },
                    child: Text(
                      'Save to Drafts',
                      style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(composeProvider.notifier).syncContent(_controller);
                      context.push('/compose/preview');
                    },
                    child: Text(
                      'Preview',
                      style: ScribesTextStyles.labelLg.copyWith(color: colors.gold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [

          Expanded(
            child: Container(
              color: colors.background,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: TextFormField(
                      controller: _titleController,
                      style: ScribesTextStyles.displayXl.copyWith(color: colors.primaryText),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: ScribesTextStyles.displayXl.copyWith(color: colors.secondaryText.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        ref.read(composeProvider.notifier).updateTitle(val);
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(height: 16),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _focusNode,
                      config: QuillEditorConfig(
                        customStyleBuilder: (Attribute attribute) {
                          if (attribute.key == 'scripture') {
                            return TextStyle(color: colors.gold, fontStyle: FontStyle.italic);
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
                  icon: const Icon(Icons.menu_book),
                  tooltip: 'Tag as Scripture',
                  onPressed: () {
                    final selection = _controller.selection;
                    if (!selection.isCollapsed) {
                      final text = _controller.document.getPlainText(
                        selection.start,
                        selection.end - selection.start,
                      );
                      if (text.trim().isNotEmpty) {
                        _controller.formatSelection(Attribute('scripture', AttributeScope.inline, text.trim()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tagged as Scripture: ${text.trim()}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Highlight text to tag as scripture')),
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
