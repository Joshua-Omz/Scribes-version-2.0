import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/media_api.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_bounce_button.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../feed/application/feed_notifier.dart';
import '../../passage/domain/passage_models.dart';
import '../../passage/domain/passage_input.dart';
import '../../passage/presentation/sound_picker_sheet.dart';
import '../../posts/data/post_repository.dart';
import '../../posts/domain/scripture_ref.dart';
import '../../bible/data/bible_repository.dart';

class PassageComposerScreen extends ConsumerStatefulWidget {
  const PassageComposerScreen({super.key});

  @override
  ConsumerState<PassageComposerScreen> createState() =>
      _PassageComposerScreenState();
}

class _LocalPanelState {
  String panelType; // 'text', 'scripture', 'reflection', 'image'
  TextEditingController textController;
  ScriptureRef? scriptureRef;
  String? scriptureText;
  bool isLoadingScripture = false;
  File? localImageFile;
  String? uploadedImageUrl;
  bool isUploadingImage = false;

  _LocalPanelState({
    required this.panelType,
    String initialText = '',
  }) : textController = TextEditingController(text: initialText);

  void dispose() {
    textController.dispose();
  }
}

class _PassageComposerScreenState extends ConsumerState<PassageComposerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<_LocalPanelState> _panels = [];
  SoundTrack? _selectedSound;
  bool _isPublishing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Default with 2 initial panels
    _panels.add(_LocalPanelState(panelType: 'text'));
    _panels.add(_LocalPanelState(panelType: 'scripture'));
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final p in _panels) {
      p.dispose();
    }
    super.dispose();
  }

  bool get _canPublish {
    if (_isPublishing) return false;
    if (_panels.length < 2 || _panels.length > 12) return false;
    for (final p in _panels) {
      if (p.isUploadingImage) return false;
      if (p.panelType == 'text' && p.textController.text.trim().isEmpty) {
        return false;
      }
      if (p.panelType == 'reflection' &&
          p.textController.text.trim().isEmpty) {
        return false;
      }
      if (p.panelType == 'scripture' && p.scriptureRef == null) {
        return false;
      }
      if (p.panelType == 'image' &&
          p.uploadedImageUrl == null &&
          p.localImageFile == null) {
        return false;
      }
    }
    return true;
  }

  void _addPanel(String type) {
    if (_panels.length >= 12) {
      ScribesToast.show(
        context,
        'Maximum 12 panels reached',
        ref.read(themeProvider),
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _panels.add(_LocalPanelState(panelType: type));
    });
  }

  void _removePanel(int index) {
    if (_panels.length <= 2) {
      ScribesToast.show(
        context,
        'A passage requires at least 2 panels',
        ref.read(themeProvider),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      final removed = _panels.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _pickImageForPanel(_LocalPanelState panel) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (picked == null) return;

      final file = File(picked.path);
      setState(() {
        panel.localImageFile = file;
        panel.isUploadingImage = true;
      });

      final mediaApi = MediaApi(ref.read(apiClientProvider));
      final uploadedUrl = await mediaApi.uploadImage(file, 'image/jpeg');

      if (mounted) {
        setState(() {
          panel.uploadedImageUrl = uploadedUrl;
          panel.isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          panel.isUploadingImage = false;
        });
        ScribesToast.show(
          context,
          'Failed to upload image: $e',
          ref.read(themeProvider),
          isError: true,
        );
      }
    }
  }

  Future<void> _fetchScriptureTextForPanel(_LocalPanelState panel) async {
    if (panel.scriptureRef == null) return;
    final refObj = panel.scriptureRef!;
    final rangeStr =
        refObj.verseEnd != null && refObj.verseEnd! > refObj.verseStart
            ? '${refObj.verseStart}-${refObj.verseEnd}'
            : '${refObj.verseStart}';
    try {
      setState(() => panel.isLoadingScripture = true);
      final bibleRepo = ref.read(bibleRepositoryProvider);
      final result = await bibleRepo.getVerseRange(
        refObj.book,
        refObj.chapter,
        rangeStr,
      );
      if (mounted) {
        setState(() {
          panel.scriptureText = result.fullText;
          panel.isLoadingScripture = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => panel.isLoadingScripture = false);
      }
    }
  }

  void _showDiscardDialog(dynamic colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScribesRadius.card),
        ),
        title: Text(
          'Discard Passage?',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to discard this passage? Your composed panels will not be saved.',
          style: ScribesTextStyles.bodyMd.copyWith(
            color: colors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Writing',
              style: ScribesTextStyles.labelLg.copyWith(
                color: colors.secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(
              'Discard',
              style: ScribesTextStyles.labelLg.copyWith(
                color: colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAndPublish() {
    final colors = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ScribesRadius.sheet),
          ),
          border: Border(
            top: BorderSide(
              color: colors.gold.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedAlertCircle,
                  color: colors.gold,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Publish Passage',
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: colors.primaryText,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Passages are immutable multi-panel compositions. Once published, panels cannot be modified.',
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ScribesBounceButton(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius:
                            BorderRadius.circular(ScribesRadius.button),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ScribesBounceButton(
                    onTap: () {
                      Navigator.pop(ctx);
                      _executePublish();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.gold,
                        borderRadius:
                            BorderRadius.circular(ScribesRadius.button),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Publish Now',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePublish() async {
    final colors = ref.read(themeProvider);
    final postRepo = ref.read(postRepositoryProvider);

    setState(() => _isPublishing = true);

    try {
      final List<CreatePassagePanelInput> panelInputs = [];

      for (final p in _panels) {
        Map<String, dynamic> contentMap = {};
        if (p.panelType == 'text' || p.panelType == 'reflection') {
          contentMap = {
            'text': p.textController.text.trim(),
            'ops': [
              {'insert': '${p.textController.text.trim()}\n'}
            ]
          };
        } else if (p.panelType == 'image') {
          contentMap = {
            'caption': p.textController.text.trim(),
            'image_url': p.uploadedImageUrl ?? '',
          };
        } else if (p.panelType == 'scripture') {
          String verseText = p.scriptureText ?? '';
          if (verseText.isEmpty && p.scriptureRef != null) {
            final refObj = p.scriptureRef!;
            final rangeStr =
                refObj.verseEnd != null && refObj.verseEnd! > refObj.verseStart
                    ? '${refObj.verseStart}-${refObj.verseEnd}'
                    : '${refObj.verseStart}';
            try {
              final bibleRepo = ref.read(bibleRepositoryProvider);
              final result = await bibleRepo.getVerseRange(
                refObj.book,
                refObj.chapter,
                rangeStr,
              );
              verseText = result.fullText;
            } catch (_) {}
          }

          contentMap = {
            'text': verseText,
            'translation': 'BSB',
            if (p.scriptureRef != null)
              'reference':
                  '${p.scriptureRef!.book} ${p.scriptureRef!.chapter}:${p.scriptureRef!.verseStart}${p.scriptureRef!.verseEnd != null ? "-${p.scriptureRef!.verseEnd}" : ""}',
            'attribution': 'Berean Standard Bible, public domain',
          };
        }

        panelInputs.add(CreatePassagePanelInput(
          panelType: p.panelType,
          content: contentMap,
          backgroundImageUrl: p.uploadedImageUrl,
          scriptureRef: p.scriptureRef,
        ));
      }

      final input = CreatePassageInput(
        title: _titleController.text,
        panels: panelInputs,
        sound: _selectedSound,
      );

      if (!input.isValid) {
        if (mounted) {
          ScribesToast.show(
            context,
            'Passage requires between 2 and 12 panels.',
            colors,
            isError: true,
          );
        }
        return;
      }

      await postRepo.createPost(input.toPayload());

      ref.invalidate(feedProvider);
      ref.invalidate(followingFeedProvider);

      if (mounted) {
        ScribesToast.show(
          context,
          'Passage published!',
          colors,
          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(
          context,
          'Failed to publish passage: $e',
          colors,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: colors.primaryText,
            size: 22,
          ),
          onPressed: () => _showDiscardDialog(colors),
        ),
        title: Text(
          'Passage',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 20,
          ),
        ),
        actions: [
          // Panel Count Gauge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(ScribesRadius.chip),
              border: Border.all(
                color: _panels.length >= 12
                    ? colors.orange
                    : _panels.length >= 8
                        ? colors.gold
                        : colors.border.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Text(
              '${_panels.length}/12 Panels',
              style: ScribesTextStyles.caption.copyWith(
                color: _panels.length >= 12
                    ? colors.orange
                    : _panels.length >= 8
                        ? colors.gold
                        : colors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Publish Button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ScribesBounceButton(
              onTap: () {
                if (_canPublish) {
                  _confirmAndPublish();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _canPublish
                      ? colors.gold
                      : colors.gold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(ScribesRadius.button),
                ),
                child: _isPublishing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: colors.background,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Publish',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Optional Title Field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _titleController,
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                  fontSize: 22,
                ),
                decoration: InputDecoration(
                  hintText: 'Devotional Title (Optional)',
                  hintStyle: ScribesTextStyles.displayMd.copyWith(
                    color: colors.secondaryText.withValues(alpha: 0.4),
                    fontSize: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // Ambient Sound Attachment Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () async {
                  final sound = await SoundPickerSheet.show(
                    context,
                    initialSound: _selectedSound,
                  );
                  setState(() => _selectedSound = sound);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(ScribesRadius.card),
                    border: Border.all(
                      color: _selectedSound != null
                          ? colors.gold.withValues(alpha: 0.5)
                          : colors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: _selectedSound != null
                            ? HugeIcons.strokeRoundedMusicNote02
                            : HugeIcons.strokeRoundedVolumeLow,
                        color: _selectedSound != null
                            ? colors.gold
                            : colors.secondaryText,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSound != null
                                  ? _selectedSound!.title
                                  : 'Attach Ambient Audio Track',
                              style: ScribesTextStyles.bodyMd.copyWith(
                                color: _selectedSound != null
                                    ? colors.primaryText
                                    : colors.secondaryText,
                                fontWeight: _selectedSound != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (_selectedSound != null)
                              Text(
                                '${_selectedSound!.category.toUpperCase()} · Continuous loop during reading',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.gold,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _selectedSound != null ? 'Change' : 'Select',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Reorderable List of Panel Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverReorderableList(
              itemCount: _panels.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _panels.removeAt(oldIndex);
                  _panels.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final panel = _panels[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(panel),
                  index: index,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(ScribesRadius.card),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Panel Card Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius:
                                    BorderRadius.circular(ScribesRadius.chip),
                                border: Border.all(
                                  color: colors.gold.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Panel ${index + 1}',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Type Switcher
                            _buildPanelTypeDropdown(panel, colors),

                            const Spacer(),

                            // Delete button
                            IconButton(
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                color: colors.secondaryText
                                    .withValues(alpha: 0.6),
                                size: 18,
                              ),
                              onPressed: () => _removePanel(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),

                            // Drag Handle
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedDrag01,
                              color: colors.secondaryText
                                  .withValues(alpha: 0.5),
                              size: 18,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Content Editor depending on Type
                        _buildPanelBodyEditor(panel, colors),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add Panel Toolbar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Next Panel:',
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildAddPanelButton(
                        '+ Text',
                        HugeIcons.strokeRoundedText,
                        () => _addPanel('text'),
                        colors,
                      ),
                      _buildAddPanelButton(
                        '+ Scripture',
                        HugeIcons.strokeRoundedBookOpen01,
                        () => _addPanel('scripture'),
                        colors,
                      ),
                      _buildAddPanelButton(
                        '+ Reflection',
                        HugeIcons.strokeRoundedHelpCircle,
                        () => _addPanel('reflection'),
                        colors,
                      ),
                      _buildAddPanelButton(
                        '+ Image',
                        HugeIcons.strokeRoundedImage01,
                        () => _addPanel('image'),
                        colors,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTypeDropdown(_LocalPanelState panel, dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(ScribesRadius.chip),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: DropdownButton<String>(
        value: panel.panelType,
        dropdownColor: colors.surfaceRaised,
        underline: const SizedBox.shrink(),
        isDense: true,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowDown01,
          color: colors.secondaryText,
          size: 14,
        ),
        items: const [
          DropdownMenuItem(value: 'text', child: Text('Text')),
          DropdownMenuItem(value: 'scripture', child: Text('Scripture')),
          DropdownMenuItem(value: 'reflection', child: Text('Reflection')),
          DropdownMenuItem(value: 'image', child: Text('Image')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => panel.panelType = val);
          }
        },
        style: ScribesTextStyles.caption.copyWith(
          color: colors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPanelBodyEditor(_LocalPanelState panel, dynamic colors) {
    switch (panel.panelType) {
      case 'text':
        return TextField(
          controller: panel.textController,
          maxLines: 4,
          style: ScribesTextStyles.bodyLg.copyWith(
            color: colors.primaryText,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter devotional teaching or commentary...',
            hintStyle: ScribesTextStyles.bodyLg.copyWith(
              color: colors.secondaryText.withValues(alpha: 0.4),
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        );

      case 'reflection':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ScribesRadius.card),
            border: Border.all(
              color: colors.gold.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: panel.textController,
            maxLines: 3,
            style: ScribesTextStyles.bodyLg.copyWith(
              color: colors.primaryText,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
            decoration: InputDecoration(
              hintText: 'Enter contemplation question or meditation prompt...',
              hintStyle: ScribesTextStyles.bodyLg.copyWith(
                color: colors.secondaryText.withValues(alpha: 0.4),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );

      case 'scripture':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (panel.scriptureRef != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(ScribesRadius.card),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBookOpen01,
                          color: colors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${panel.scriptureRef!.book} ${panel.scriptureRef!.chapter}:${panel.scriptureRef!.verseStart}${panel.scriptureRef!.verseEnd != null ? '-${panel.scriptureRef!.verseEnd}' : ''}',
                            style: ScribesTextStyles.bodyMd.copyWith(
                              color: colors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          onPressed: () => setState(() {
                            panel.scriptureRef = null;
                            panel.scriptureText = null;
                          }),
                        ),
                      ],
                    ),
                    if (panel.isLoadingScripture) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.gold,
                        ),
                      ),
                    ] else if (panel.scriptureText != null &&
                        panel.scriptureText!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '“${panel.scriptureText}”',
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () {
                  ScribesScriptureSelector.show(
                    context,
                    colors: colors,
                    onSelected: (book, chapter, verseStart, verseEnd) {
                      setState(() {
                        panel.scriptureRef = ScriptureRef(
                          book: book,
                          chapter: chapter ?? 1,
                          verseStart: verseStart ?? 1,
                          verseEnd: verseEnd,
                        );
                      });
                      _fetchScriptureTextForPanel(panel);
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(ScribesRadius.card),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: colors.gold,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Select Bible passage verse...',
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );

      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (panel.localImageFile != null ||
                panel.uploadedImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(ScribesRadius.card),
                child: Stack(
                  children: [
                    if (panel.localImageFile != null)
                      Image.file(
                        panel.localImageFile!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else if (panel.uploadedImageUrl != null)
                      Image.network(
                        panel.uploadedImageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    if (panel.isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.gold,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            panel.localImageFile = null;
                            panel.uploadedImageUrl = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: panel.textController,
                style: ScribesTextStyles.caption.copyWith(
                  color: colors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'Image caption / meditation note (optional)...',
                  hintStyle: ScribesTextStyles.caption.copyWith(
                    color: colors.secondaryText.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () => _pickImageForPanel(panel),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(ScribesRadius.card),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedImage01,
                        color: colors.gold,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to choose panel image',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddPanelButton(
    String label,
    List<List<dynamic>> iconData,
    VoidCallback onTap,
    dynamic colors,
  ) {
    final isDisabled = _panels.length >= 12;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled
              ? colors.surfaceRaised.withValues(alpha: 0.5)
              : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(ScribesRadius.chip),
          border: Border.all(
            color: isDisabled
                ? colors.border.withValues(alpha: 0.2)
                : colors.gold.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: iconData,
              color: isDisabled ? colors.secondaryText : colors.gold,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: ScribesTextStyles.caption.copyWith(
                color: isDisabled ? colors.secondaryText : colors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
