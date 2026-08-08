import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/network/media_api.dart';
import '../../posts/domain/sermon_source.dart';
import '../../posts/domain/scripture_ref.dart';
import '../application/compose_provider.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../search/data/search_repository.dart';

class PublishMetadataScreen extends ConsumerStatefulWidget {
  const PublishMetadataScreen({super.key});

  @override
  ConsumerState<PublishMetadataScreen> createState() => _PublishMetadataScreenState();
}

class _PublishMetadataScreenState extends ConsumerState<PublishMetadataScreen> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();
  bool _isUploadingCover = false;

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _showPublishConfirmation(BuildContext context, WidgetRef ref) {
    final colors = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Publish Post?',
                style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 16),
              Text(
                'Publishing creates a public post that cannot be erased. It will be permanently added to your scroll and visible to your followers.',
                textAlign: TextAlign.center,
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Not yet', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.gold,
                        foregroundColor: colors.surfaceRaised,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(composeProvider.notifier).publishToCloud().then((_) {
                          if (context.mounted) {
                            ScribesToast.show(context, 'Post published!', colors, icon: HugeIcons.strokeRoundedCheckmarkBadge01);
                            context.go('/');
                          }
                        }).catchError((err) {
                          if (context.mounted) {
                            ScribesToast.show(context, 'Error publishing: $err', colors, isError: true);
                          }
                        });
                      },
                      child: Text('Publish', style: ScribesTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadCoverImage() async {
    final colors = ref.read(themeProvider);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final cropper = ImageCropper();
      final croppedFile = await cropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Cover Image',
            toolbarColor: colors.surface,
            toolbarWidgetColor: colors.primaryText,
            activeControlsWidgetColor: colors.gold,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Cover Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() => _isUploadingCover = true);

      final mediaApi = ref.read(mediaApiProvider);
      String mimeType = 'image/jpeg';
      if (croppedFile.path.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (croppedFile.path.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      final uploadedUrl = await mediaApi.uploadImage(File(croppedFile.path), mimeType);
      
      ref.read(composeProvider.notifier).updateMetadata(coverImageUrl: uploadedUrl);

      if (mounted) {
        ScribesToast.show(context, 'Cover image added!', colors);
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(context, 'Failed to upload image: $e', colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  void _removeCoverImage() {
    ref.read(composeProvider.notifier).updateMetadata(coverImageUrl: null);
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
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () {
            context.pop(); // Go back to Preview
          },
        ),
        title: Text(
          'Post Details',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (composeState.title.trim().isEmpty) {
                ScribesToast.show(context, 'Please add a title before publishing.', colors, isError: true);
                return;
              }
              if (composeState.contentDelta == null) {
                ScribesToast.show(context, 'Post body cannot be empty.', colors, isError: true);
                return;
              }
              if (composeState.scriptureRefs.length < 2) {
                ScribesToast.show(context, 'Please add between 2 and 3 scripture tags.', colors, isError: true);
                return;
              }
              _showPublishConfirmation(context, ref);
            },
            child: Text(
              'Publish',
              style: ScribesTextStyles.labelLg.copyWith(color: colors.orange),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: colors.background,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Context is everything.',
                      style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add optional metadata to help others discover your post.',
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText, height: 1.5),
                    ),
                  ],
                ),
              ),
              
              // Form Area
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: colors.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Type Selection
                    Text(
                      'Post Type',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref.read(composeProvider.notifier).updateMetadata(postType: 'standard'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: composeState.postType == 'standard' ? colors.gold.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Standard',
                                    style: ScribesTextStyles.labelLg.copyWith(
                                      color: composeState.postType == 'standard' ? colors.gold : colors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 24, color: colors.border),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ref.read(composeProvider.notifier).updateMetadata(postType: 'passage'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: composeState.postType == 'passage' ? colors.gold.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Passage',
                                    style: ScribesTextStyles.labelLg.copyWith(
                                      color: composeState.postType == 'passage' ? colors.gold : colors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Cover Image Selection (Standard posts only)
                    if (composeState.postType == 'standard') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cover Image',
                            style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                          ),
                          if (composeState.coverImageUrl != null)
                            TextButton(
                              onPressed: _removeCoverImage,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Remove', style: ScribesTextStyles.labelSm.copyWith(color: colors.orange)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isUploadingCover ? null : _pickAndUploadCoverImage,
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.border),
                            image: composeState.coverImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(composeState.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _isUploadingCover
                              ? Center(child: CircularProgressIndicator(color: colors.gold))
                              : composeState.coverImageUrl == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: colors.secondaryText, size: 32),
                                        const SizedBox(height: 8),
                                        Text('Add Cover Image (Optional)', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                                        const SizedBox(height: 4),
                                        Text('Recommended aspect ratio: 16:9', style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText)),
                                      ],
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Scripture Tags Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scripture Tags',
                              style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add 2 to 3 scripture references.',
                              style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                        if (composeState.scriptureRefs.length < 3)
                          TextButton.icon(
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, size: 16, color: colors.gold),
                            label: Text('Add', style: ScribesTextStyles.labelLg.copyWith(color: colors.gold)),
                            onPressed: () => _showAddScriptureSheet(context, ref, colors),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (composeState.scriptureRefs.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: composeState.scriptureRefs.map((refData) {
                          final refStr = refData.verseEnd != null
                              ? '${refData.book} ${refData.chapter}:${refData.verseStart}-${refData.verseEnd}'
                              : '${refData.book} ${refData.chapter}:${refData.verseStart}';
                          return InputChip(
                            label: Text(
                              refStr,
                              style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
                            ),
                            onDeleted: () => ref.read(composeProvider.notifier).removeScriptureRef(refData),
                            backgroundColor: colors.surfaceRaised,
                            deleteIconColor: colors.secondaryText,
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 40),

                    // --- Tags Section ---
                    const SizedBox(height: 16),
                    Text(
                      'Tags',
                      style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add up to 8 tags to help others find your post (e.g. grace, prophecy).',
                      style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    if (composeState.tags.isNotEmpty)
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: composeState.tags.map((tag) {
                          return InputChip(
                            label: Text(
                              "#$tag",
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: colors.surface,
                              ),
                            ),
                            backgroundColor: colors.primaryText,
                            deleteIconColor: colors.surface,
                            onDeleted: () {
                              ref.read(composeProvider.notifier).removeTag(tag);
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      ),
                    if (composeState.tags.isNotEmpty) const SizedBox(height: 12),
                    if (composeState.tags.length < 8)
                      RawAutocomplete<String>(
                        focusNode: _tagFocusNode,
                        textEditingController: _tagController,
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          final query = textEditingValue.text.replaceAll(',', '').trim();
                          if (query.isEmpty) return const Iterable<String>.empty();
                          try {
                            final repo = ref.read(searchRepositoryProvider);
                            return await repo.suggestTags(query);
                          } catch (_) {
                            return const Iterable<String>.empty();
                          }
                        },
                        onSelected: (String selection) {
                          ref.read(composeProvider.notifier).addTag(selection);
                          _tagController.clear();
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          return ScribesTextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            hintText: 'Add a tag (press Enter or comma)',
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                ref.read(composeProvider.notifier).addTag(value);
                                textEditingController.clear();
                              }
                            },
                            onChanged: (value) {
                              if (value.endsWith(',') || value.endsWith(' ')) {
                                final tag = value.substring(0, value.length - 1);
                                if (tag.trim().isNotEmpty) {
                                  ref.read(composeProvider.notifier).addTag(tag);
                                  textEditingController.clear();
                                }
                              }
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              color: colors.surface,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 200, maxWidth: MediaQuery.of(context).size.width - 48),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final String option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text('#$option', style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),

                    // Caption Field
                    Text(
                      'Caption',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    ScribesTextField(
                      initialValue: composeState.caption,
                      maxLines: 4,
                      minLines: 2,
                      hintText: 'Share a thought about this note...',
                      onChanged: (value) => ref.read(composeProvider.notifier).updateMetadata(caption: value),
                    ),
                    const SizedBox(height: 40),

                    // Sermon Details Section
                    Text(
                      'Sermon Details',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          _buildPremiumField(
                            label: 'Preacher',
                            icon: HugeIcons.strokeRoundedUser,
                            initialValue: composeState.sermonSource?.preacher,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(preacher: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          _buildPremiumField(
                            label: 'Church',
                            icon: HugeIcons.strokeRoundedChurch,
                            initialValue: composeState.sermonSource?.church,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(church: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          _buildPremiumField(
                            label: 'Series',
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            initialValue: composeState.sermonSource?.series,
                            colors: colors,
                            onChanged: (value) {
                              final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                              ref.read(composeProvider.notifier).updateMetadata(sermonSource: src.copyWith(series: value));
                            },
                          ),
                          Divider(height: 1, color: colors.border, indent: 48),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: colors.gold,
                                        onPrimary: colors.surfaceRaised,
                                        surface: colors.surface,
                                        onSurface: colors.primaryText,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                final src = composeState.sermonSource ?? const SermonSource(preacher: '');
                                ref.read(composeProvider.notifier).updateMetadata(
                                  sermonSource: src.copyWith(date: date.toIso8601String().split('T')[0]),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, size: 20, color: colors.secondaryText),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      composeState.sermonSource?.date ?? 'Date Preached',
                                      style: ScribesTextStyles.bodyMd.copyWith(
                                        color: composeState.sermonSource?.date == null 
                                          ? colors.secondaryText.withValues(alpha: 0.5) 
                                          : colors.primaryText,
                                      ),
                                    ),
                                  ),
                                  HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20, color: colors.secondaryText.withValues(alpha: 0.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumField({
    required String label,
    required dynamic icon,
    required String? initialValue,
    required dynamic colors,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 20, color: colors.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: ScribesTextField(
              initialValue: initialValue,
              hintText: label,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScriptureSheet(BuildContext context, WidgetRef ref, dynamic colors) {
    ScribesScriptureSelector.show(
      context,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        if (chapter != null && verseStart != null) {
          ref.read(composeProvider.notifier).addScriptureRef(
            ScriptureRef(
              book: book,
              chapter: chapter,
              verseStart: verseStart,
              verseEnd: verseEnd,
            ),
          );
        }
      },
    );
  }
}
