import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_quill_scripture_helper.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_scripture_quick_dialog.dart';
import '../../../core/theme/scribes_quill_auto_number_rule.dart';
import '../../../core/widgets/scribes_quill_toolbar.dart';
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
  String? _activeInlineScripture;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _tagController = TextEditingController();
    _tags = List<String>.from(widget.post.tags);

    // The backend expects rich text delta for the 'body' within the content json
    final content = widget.post.content;
    var bodyData = content['body'];

    if (bodyData != null && bodyData is List && bodyData.isNotEmpty) {
      try {
        final doc = Document.fromJson(bodyData);
        _controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _controller = QuillController.basic();
      }
    } else {
      _controller = QuillController.basic();
    }
    _controller.addListener(_onDocumentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    _captionController.dispose();
    _tagController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onDocumentChanged() {
    final active = ScribesQuillScriptureHelper.getActiveScriptureReference(
      _controller,
    );
    if (active != _activeInlineScripture) {
      setState(() {
        _activeInlineScripture = active;
      });
    }
  }

  void _saveRevision() async {
    final colors = ref.read(themeProvider);
    final delta = _controller.document.toDelta().toJson();
    final caption = _captionController.text.trim();

    // Construct the revised content retaining original metadata
    final newContent = Map<String, dynamic>.from(widget.post.content);
    newContent['body'] = delta;

    await ref
        .read(revisePostProvider.notifier)
        .revisePost(
          widget.post.id,
          newContent,
          caption.isNotEmpty ? caption : null,
          _tags,
        );

    final state = ref.read(revisePostProvider);
    if (!state.hasError && mounted) {
      ScribesToast.show(
        context,
        'Post revised successfully',
        colors,
        icon: HugeIcons.strokeRoundedCheckmarkBadge01,
      );
      context.pop();
    } else if (mounted) {
      ScribesToast.show(
        context,
        'Error revising post: ${state.error}',
        colors,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(revisePostProvider);

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
                              onTap: () {
                                ScribesScriptureQuickDialog.show(
                                  context,
                                  reference: _activeInlineScripture!,
                                  onRemove: () {
                                    ScribesQuillScriptureHelper.removeScriptureAttribute(
                                      _controller,
                                    );
                                    setState(() => _activeInlineScripture = null);
                                  },
                                );
                              },
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
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: colors.secondaryText,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add up to 8 tags (e.g. grace, prophecy).',
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.secondaryText.withValues(alpha: 0.7),
                    ),
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
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.gold,
                            ),
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
          ScribesQuillToolbar(
            controller: _controller,
            colors: colors,
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
