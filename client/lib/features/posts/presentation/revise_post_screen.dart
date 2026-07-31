import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../domain/post.dart';
import '../application/revise_post_provider.dart';

class RevisePostScreen extends ConsumerStatefulWidget {
  final Post post;

  const RevisePostScreen({super.key, required this.post});

  @override
  ConsumerState<RevisePostScreen> createState() => _RevisePostScreenState();
}

class _RevisePostScreenState extends ConsumerState<RevisePostScreen> {
  late final QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _captionController;
  late final TextEditingController _tagController;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _tagController = TextEditingController();
    _tags = List<String>.from(widget.post.tags);

    // The backend expects rich text delta for the 'body' within the content json
    final content = widget.post.content;
    var bodyData = content['body'];

    if (bodyData != null && bodyData is List) {
      final doc = Document.fromJson(bodyData);
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    _tagController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveRevision() async {
    final colors = ref.read(themeProvider);
    final delta = _controller.document.toDelta().toJson();
    final caption = _captionController.text.trim();

    // Construct the revised content retaining original metadata
    final newContent = Map<String, dynamic>.from(widget.post.content);
    newContent['body'] = delta;

    await ref
        .read(revisePostNotifierProvider.notifier)
        .revisePost(
          widget.post.id,
          newContent,
          caption.isNotEmpty ? caption : null,
          _tags,
        );

    final state = ref.read(revisePostNotifierProvider);
    if (!state.hasError && mounted) {
      ScribesToast.show(
        context,
        'Post updated successfully',
        colors,
        icon: HugeIcons.strokeRoundedCheckmarkBadge01,
      );
      context.pop();
    } else if (state.hasError && mounted) {
      ScribesToast.show(
        context,
        'Failed to update post',
        colors,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(revisePostNotifierProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: colors.primaryText,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Edit Post',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          state.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveRevision,
                  child: Text(
                    'Save',
                    style: ScribesTextStyles.labelLg.copyWith(
                      color: colors.gold,
                    ),
                  ),
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: colors.background,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.post.content['title'] ?? 'Untitled',
                    style: ScribesTextStyles.displayXl.copyWith(
                      color: colors.primaryText.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _focusNode,
                      scrollController: _scrollController,
                      config: QuillEditorConfig(
                        customStyleBuilder: (Attribute attribute) {
                          if (attribute.key == 'scripture') {
                            return TextStyle(
                              color: colors.gold,
                              fontStyle: FontStyle.italic,
                            );
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
                  Divider(height: 1, thickness: 1, color: colors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _captionController,
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add an optional caption...',
                        hintStyle: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedText,
                          size: 20,
                          color: colors.secondaryText,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tags Section
                  Text(
                    'Tags',
                    style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add up to 8 tags (e.g. grace, prophecy).',
                    style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 8),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _tags.map((tag) {
                        return InputChip(
                          label: Text(
                            "#$tag",
                            style: ScribesTextStyles.labelSm.copyWith(color: colors.gold),
                          ),
                          backgroundColor: colors.surfaceRaised,
                          deleteIconColor: colors.orange,
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  if (_tags.isNotEmpty) const SizedBox(height: 12),
                  if (_tags.length < 8)
                    ScribesTextField(
                      controller: _tagController,
                      hintText: 'Add a tag (press Enter or comma)',
                      onSubmitted: (value) {
                        _addTag(value);
                      },
                      onChanged: (value) {
                        if (value.endsWith(',')) {
                          final tag = value.substring(0, value.length - 1);
                          _addTag(tag);
                        }
                      },
                    ),
                  const SizedBox(height: 16),
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
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedBookOpen01),
                  tooltip: 'Tag as Scripture',
                  onPressed: () {
                    final selection = _controller.selection;
                    if (!selection.isCollapsed) {
                      final text = _controller.document.getPlainText(
                        selection.start,
                        selection.end - selection.start,
                      );
                      if (text.trim().isNotEmpty) {
                        _controller.formatSelection(
                          Attribute(
                            'scripture',
                            AttributeScope.inline,
                            text.trim(),
                          ),
                        );
                        final colors = ref.read(themeProvider);
                        ScribesToast.show(
                          context,
                          'Tagged as Scripture: ${text.trim()}',
                          colors,
                          icon: HugeIcons.strokeRoundedBookOpen01,
                        );
                      }
                    } else {
                      final colors = ref.read(themeProvider);
                      ScribesToast.show(
                        context,
                        'Highlight text to tag as scripture',
                        colors,
                        icon: HugeIcons.strokeRoundedBookOpen01,
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

  void _addTag(String value) {
    final tag = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 8) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }
}
