import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../application/compose_provider.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    ref.read(composeProvider.notifier).onDocumentChanged(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final composeState = ref.watch(composeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        title: Text(
          'New Draft',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          if (composeState.isSaving)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.gold,
                  ),
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              // Trigger publish
              ref.read(composeProvider.notifier).publishToCloud().then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Draft published!')),
                  );
                }
              }).catchError((err) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error publishing: $err')),
                  );
                }
              });
            },
            child: Text(
              'Publish',
              style: ScribesTextStyles.labelLg.copyWith(
                color: colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(
            controller: _controller,
            config: QuillSimpleToolbarConfig(
              color: colors.surface,
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
          Divider(height: 1, thickness: 1, color: colors.border),
          Expanded(
            child: Container(
              color: colors.background,
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _controller,
                config: QuillEditorConfig(
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(16, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    h1: DefaultTextBlockStyle(
                      ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(32, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    h2: DefaultTextBlockStyle(
                      ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                      const HorizontalSpacing(0, 0),
                      const VerticalSpacing(24, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
