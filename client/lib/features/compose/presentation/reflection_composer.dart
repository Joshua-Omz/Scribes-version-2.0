import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/widgets/scribes_bounce_button.dart';
import '../../../core/widgets/scribes_image_resolver.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/network/media_api.dart';
import '../../auth/application/auth_notifier.dart';
import '../../posts/data/post_repository.dart';
import '../../posts/domain/scripture_ref.dart';
import '../../reflection/domain/reflection_models.dart';
import '../../feed/application/feed_notifier.dart';

/// Lightweight, modern, immutable Reflection Composer.
/// Scribes Source of Truth: docs/contracts/reflection_type_post.md
class ReflectionComposerScreen extends ConsumerStatefulWidget {
  const ReflectionComposerScreen({super.key});

  @override
  ConsumerState<ReflectionComposerScreen> createState() =>
      _ReflectionComposerScreenState();
}

class _ReflectionComposerScreenState
    extends ConsumerState<ReflectionComposerScreen> {
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _bodyFocus = FocusNode();

  ScriptureRef? _attachedScripture;
  String? _imagePath;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isPublishing = false;

  final int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _bodyController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  int get _charCount => _bodyController.text.trim().length;
  bool get _isOverLimit => _charCount > _maxChars;
  bool get _canPublish =>
      _charCount > 0 &&
      !_isOverLimit &&
      !_isUploadingImage &&
      !_isPublishing;

  Future<void> _pickAndUploadPhoto() async {
    final colors = ref.read(themeProvider);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 88,
      );
      if (picked == null) return;

      setState(() {
        _imagePath = picked.path;
        _isUploadingImage = true;
      });

      final mediaApi = ref.read(mediaApiProvider);
      String mimeType = 'image/jpeg';
      if (picked.path.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (picked.path.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      try {
        final url = await mediaApi.uploadImage(File(picked.path), mimeType);
        setState(() {
          _uploadedImageUrl = url;
        });
      } catch (e) {
        if (mounted) {
          ScribesToast.show(
            context,
            'Failed to upload photo to cloud: $e',
            colors,
            isError: true,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _imagePath = null;
      _uploadedImageUrl = null;
    });
  }

  void _openScripturePicker() {
    final colors = ref.read(themeProvider);
    ScribesScriptureSelector.show(
      context,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        if (chapter != null && verseStart != null) {
          setState(() {
            _attachedScripture = ScriptureRef(
              book: book,
              chapter: chapter,
              verseStart: verseStart,
              verseEnd: verseEnd,
            );
          });
        }
      },
    );
  }

  void _removeScripture() {
    setState(() {
      _attachedScripture = null;
    });
  }

  Future<void> _confirmAndPublish() async {
    final colors = ref.read(themeProvider);
    final authUser = ref.read(authProvider).value;

    if (authUser == null) {
      ScribesToast.show(
        context,
        'Please sign in to publish your reflection.',
        colors,
        isError: false,
      );
      context.push('/auth');
      return;
    }

    // Show Immutability Confirmation Sheet
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.gold.withValues(alpha: 0.12),
                border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedQuillWrite02,
                color: colors.gold,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Publish Reflection?',
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Reflections are immutable timestamps on the global scroll and cannot be edited after posting.',
              textAlign: TextAlign.center,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Edit More',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surfaceRaised,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Publish Now',
                      style: ScribesTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
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

    if (!mounted || confirmed != true) return;

    if (_imagePath != null && _uploadedImageUrl == null) {
      if (_isUploadingImage) {
        if (mounted) {
          ScribesToast.show(
            context,
            'Please wait for photo upload to finish.',
            colors,
            isError: false,
          );
        }
        return;
      } else {
        if (mounted) {
          ScribesToast.show(
            context,
            'Photo upload failed. Please remove photo or try again.',
            colors,
            isError: true,
          );
        }
        return;
      }
    }

    setState(() => _isPublishing = true);

    try {
      final postRepo = ref.read(postRepositoryProvider);
      final input = CreateReflectionInput(
        body: _bodyController.text,
        scriptureRef: _attachedScripture,
        uploadedImageUrl: _uploadedImageUrl,
      );

      if (!input.isValid) {
        if (mounted) {
          ScribesToast.show(
            context,
            'Reflection must be between 1 and 500 characters.',
            colors,
            isError: true,
          );
        }
        return;
      }

      await postRepo.createPost(input.toPayload());

      // Invalidate feed to show the new reflection immediately
      ref.invalidate(feedProvider);
      ref.invalidate(followingFeedProvider);

      if (mounted) {
        ScribesToast.show(
          context,
          'Reflection published!',
          colors,
          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(
          context,
          'Failed to publish: $e',
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
    final authUser = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: colors.primaryText,
            size: 22,
          ),
          onPressed: () {
            if (_charCount > 0) {
              _showDiscardDialog(colors);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Reflection',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ScribesBounceButton(
              onTap: () {
                if (_canPublish) {
                  _confirmAndPublish();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          strokeWidth: 2,
                          color: colors.surfaceRaised,
                        ),
                      )
                    : Text(
                        'Post',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: _canPublish
                              ? colors.surfaceRaised
                              : colors.surfaceRaised.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Author Header Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colors.surfaceRaised,
                        backgroundImage: authUser?.avatarUrl != null
                            ? NetworkImage(authUser!.avatarUrl!)
                            : null,
                        child: authUser?.avatarUrl == null
                            ? HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                color: colors.secondaryText,
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authUser?.displayName ?? 'Anonymous Scribe',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            authUser != null
                                ? '@${authUser.handle}'
                                : 'Guest Scribe',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colors.gold.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Moment',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Main Thought Input Area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(ScribesRadius.card),
                      border: Border.all(
                        color: _isOverLimit
                            ? colors.orange
                            : colors.border.withValues(alpha: 0.7),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _bodyController,
                          focusNode: _bodyFocus,
                          maxLines: null,
                          minLines: 5,
                          keyboardType: TextInputType.multiline,
                          style: ScribesTextStyles.bodyLg.copyWith(
                            color: colors.primaryText,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'What thought, verse, or question is on your heart today?',
                            hintStyle: ScribesTextStyles.bodyLg.copyWith(
                              color: colors.secondaryText.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Character Count Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$_charCount / $_maxChars',
                              style: ScribesTextStyles.caption.copyWith(
                                color: _isOverLimit
                                    ? colors.orange
                                    : _charCount > 400
                                        ? colors.gold
                                        : colors.secondaryText.withValues(
                                            alpha: 0.6,
                                          ),
                                fontWeight: _charCount > 400
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attached Scripture Card (if selected)
                  if (_attachedScripture != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(ScribesRadius.card),
                        border: Border.all(
                          color: colors.gold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.gold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedBookOpen01,
                              color: colors.gold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quoted Scripture',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: colors.gold,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _attachedScripture!.verseEnd != null
                                      ? '${_attachedScripture!.book} ${_attachedScripture!.chapter}:${_attachedScripture!.verseStart}-${_attachedScripture!.verseEnd}'
                                      : '${_attachedScripture!.book} ${_attachedScripture!.chapter}:${_attachedScripture!.verseStart}',
                                  style: ScribesTextStyles.labelLg.copyWith(
                                    color: colors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: colors.secondaryText,
                              size: 16,
                            ),
                            onPressed: _removeScripture,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attached Photo Preview (if selected)
                  if (_imagePath != null) ...[
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(ScribesRadius.card),
                        border: Border.all(color: colors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ScribesImageResolver.buildImage(
                              imageUrl: _uploadedImageUrl ?? _imagePath,
                              fit: BoxFit.cover,
                              memCacheWidth: 800,
                              placeholder: (ctx, url) => Center(
                                child: CircularProgressIndicator(
                                  color: colors.gold,
                                ),
                              ),
                              errorWidget: (ctx, url, err) => Center(
                                child: Text(
                                  'Preview unavailable',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black45,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colors.gold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: _removePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancel01,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attachment Buttons Bar
                  Row(
                    children: [
                      // Scripture Attachment Button
                      if (_attachedScripture == null) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primaryText,
                            side: BorderSide(
                              color: colors.border.withValues(alpha: 0.8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScribesRadius.button,
                              ),
                            ),
                          ),
                          onPressed: _openScripturePicker,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            color: colors.gold,
                            size: 16,
                          ),
                          label: Text(
                            'Attach Scripture',
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.primaryText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Photo Attachment Button
                      if (_imagePath == null) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primaryText,
                            side: BorderSide(
                              color: colors.border.withValues(alpha: 0.8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScribesRadius.button,
                              ),
                            ),
                          ),
                          onPressed: _isUploadingImage ? null : _pickAndUploadPhoto,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedImage01,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          label: Text(
                            'Attach Photo',
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Immutability Notice Callout
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(ScribesRadius.card),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          color: colors.secondaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Reflections cannot be edited after publishing. They stand as a permanent snapshot on your scroll.',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscardDialog(dynamic colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Discard Reflection?',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Your drafted reflection will be lost.',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
