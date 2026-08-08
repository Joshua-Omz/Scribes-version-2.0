import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/network/media_api.dart';
import '../../auth/application/auth_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _handleCtrl;
  late TextEditingController _bioCtrl;
  bool _isChurch = false;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _handleCtrl = TextEditingController(text: user?.handle ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? ''); 
    _isChurch = user?.isChurch ?? false;
    _avatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _handleCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final displayName = _nameCtrl.text.trim();
    final handle = _handleCtrl.text.trim();
    final bio = _bioCtrl.text.trim();
    final colors = ref.read(themeProvider);

    if (displayName.isEmpty || handle.isEmpty) {
      ScribesToast.show(context, 'Display name and handle are required', colors, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            handle: handle,
            displayName: displayName,
            bio: bio.isEmpty ? null : bio,
            isChurch: _isChurch,
            avatarUrl: _avatarUrl,
          );
      if (mounted) {
        ScribesToast.show(context, 'Profile updated successfully!', colors);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(context, e.toString(), colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final colors = ref.read(themeProvider);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final cropper = ImageCropper();
      final croppedFile = await cropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            toolbarColor: colors.surface,
            toolbarWidgetColor: colors.primaryText,
            activeControlsWidgetColor: colors.gold,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Avatar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final mediaApi = ref.read(mediaApiProvider);
      
      // Determine mime type based on file extension
      String mimeType = 'image/jpeg';
      if (croppedFile.path.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (croppedFile.path.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      final uploadedUrl = await mediaApi.uploadImage(File(croppedFile.path), mimeType);
      
      setState(() {
        _avatarUrl = uploadedUrl;
      });

      if (mounted) {
        ScribesToast.show(context, 'Avatar uploaded successfully!', colors);
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(context, 'Failed to upload avatar: $e', colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.gold),
                  )
                : Text('Save', style: ScribesTextStyles.labelLg.copyWith(color: colors.gold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ScribesAvatar(
                    authorName: user?.displayName ?? 'A',
                    imageUrl: _avatarUrl,
                    radius: 48,
                  ),
                  if (_isUploadingAvatar)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(color: colors.gold),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.background, width: 4),
                    ),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedCamera01, size: 16, color: colors.surfaceRaised),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ScribesTextField(
              labelText: 'Display Name',
              controller: _nameCtrl,
            ),
            const SizedBox(height: 24),
            ScribesTextField(
              labelText: 'Handle',
              controller: _handleCtrl,
            ),
            const SizedBox(height: 24),
            ScribesTextField(
              labelText: 'Bio',
              controller: _bioCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: SwitchListTile(
                title: Text('This is a Church account', style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText)),
                subtitle: Text('Church accounts get special features', style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText)),
                value: _isChurch,
                onChanged: (val) => setState(() => _isChurch = val),
                activeThumbColor: colors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
