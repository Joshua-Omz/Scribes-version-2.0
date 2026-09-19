import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/theme/scribes_quill_scripture_helper.dart';
import 'package:scribes/core/widgets/scribes_scripture_quick_dialog.dart';

class PostRichText extends StatefulWidget {
  final List<dynamic> content;

  const PostRichText({super.key, required this.content});

  @override
  State<PostRichText> createState() => _PostRichTextState();
}

class _PostRichTextState extends State<PostRichText> {
  late final QuillController _controller;
  late final FocusNode _focusNode;
  String? _lastTappedRef;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: false);
    Document document;
    try {
      if (widget.content.isNotEmpty) {
        document = Document.fromJson(widget.content);
      } else {
        document = Document();
      }
    } catch (_) {
      document = Document();
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: -1),
      readOnly: true,
    );
    _controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant PostRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      try {
        if (widget.content.isNotEmpty) {
          _controller.document = Document.fromJson(widget.content);
        } else {
          _controller.document = Document();
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSelectionChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    final ref = ScribesQuillScriptureHelper.getActiveScriptureReference(
      _controller,
    );
    if (ref != null && ref.isNotEmpty) {
      final now = DateTime.now();
      // Debounce opening dialog if tapped rapidly
      if (_lastTappedRef != ref ||
          _lastTapTime == null ||
          now.difference(_lastTapTime!).inMilliseconds > 600) {
        _lastTappedRef = ref;
        _lastTapTime = now;
        if (mounted) {
          ScribesScriptureQuickDialog.show(context, reference: ref);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ScribesColors>()!;

    return QuillEditor.basic(
      controller: _controller,
      focusNode: _focusNode,
      config: QuillEditorConfig(
        scrollable: false,
        autoFocus: false,
        expands: false,
        padding: EdgeInsets.zero,
        showCursor: false,
        enableSelectionToolbar: false,
        readOnlyMouseCursor: SystemMouseCursors.basic,
        customStyleBuilder: (Attribute attribute) {
          if (attribute.key == 'scripture') {
            return ScribesQuillScriptureHelper.buildScriptureTextStyle(colors);
          }
          return const TextStyle();
        },
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(2, 10),
            const VerticalSpacing(0, 0),
            null,
          ),
          quote: DefaultTextBlockStyle(
            ScribesTextStyles.bodyLg.copyWith(
              color: colors.primaryText,
              fontStyle: FontStyle.italic,
            ),
            const HorizontalSpacing(16, 16),
            const VerticalSpacing(8, 10),
            const VerticalSpacing(0, 0),
            BoxDecoration(
              border: Border(left: BorderSide(color: colors.gold, width: 4)),
            ),
          ),
        ),
      ),
    );
  }
}
