import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_auto_save_dot.dart';
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
  }

  Future<void> _promoteToDraft() async {
    final colors = ref.read(themeProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Trigger promotion logic
    await ref.read(noteEditorProvider.notifier).promoteToDraft();
    
    // Load content into draft composer
    final noteState = ref.read(noteEditorProvider);
    ref.read(composeProvider.notifier).reset();
    
    // Copy the delta to new draft
    final draftNotifier = ref.read(composeProvider.notifier);
    draftNotifier.updateTitle(noteState.title);
    // Actually we can just sync the exact same Quill Document to the Draft provider by passing a fake controller. 
    // Or we simply redirect to drafts/compose and the provider will load it. Wait, the Draft's initial state needs the delta.
    
    // Reset compose provider and set its state
    draftNotifier.loadDraft(
      '', // new draft id or we let it generate one
      {
        'title': noteState.title,
        'body': noteState.contentDelta,
      }
    );

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Note moved to drafts!'),
        backgroundColor: colors.surfaceRaised,
      ),
    );

    if (mounted) {
      context.go('/compose'); // Navigate to the draft editor directly
    }
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
                        state: composeState.isSaving ? SaveState.saving : SaveState.localSaved,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _promoteToDraft,
                    icon: Icon(Icons.drive_file_move_outline, color: colors.orange, size: 18),
                    label: Text(
                      'Move to Drafts',
                      style: ScribesTextStyles.labelLg.copyWith(color: colors.orange),
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
                  const SizedBox(height: 16),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: QuillEditorConfig(
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
            ),
          ),
        ],
      ),
    );
  }
}
