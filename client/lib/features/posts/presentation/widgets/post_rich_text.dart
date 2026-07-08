import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';

class PostRichText extends StatelessWidget {
  final List<dynamic> content;

  const PostRichText({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ScribesColors>()!;

    Document document;
    try {
      document = Document.fromJson(content);
    } catch (e) {
      return Text('Failed to load document: $e', style: TextStyle(color: colors.primaryText));
    }

    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    return QuillEditor.basic(
      controller: controller,
      config: QuillEditorConfig(
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          quote: DefaultTextBlockStyle(
            ScribesTextStyles.bodyLg.copyWith(
              color: colors.primaryText,
              fontStyle: FontStyle.italic,
            ),
            const HorizontalSpacing(16, 16),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            BoxDecoration(
              border: Border(
                left: BorderSide(color: colors.gold, width: 4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
