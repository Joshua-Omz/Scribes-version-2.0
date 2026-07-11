import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../auth/application/auth_notifier.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _bioCtrl = TextEditingController(text: ''); // User domain model currently lacks bio
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
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
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement backend patch
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              context.pop();
            },
            child: Text('Save', style: ScribesTextStyles.labelLg.copyWith(color: colors.gold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ScribesAvatar(
                  authorName: user?.displayName ?? 'A',
                  size: 96,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.background, width: 4),
                  ),
                  child: Icon(Icons.camera_alt, size: 16, color: colors.surfaceRaised),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildInput('Display Name', _nameCtrl, colors),
            const SizedBox(height: 24),
            _buildInput('Bio', _bioCtrl, colors, maxLines: 3),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, dynamic colors, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ScribesTextStyles.caption.copyWith(
            color: colors.secondaryText,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScribesRadius.input),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ScribesRadius.input),
              borderSide: BorderSide(color: colors.gold, width: 1.5),
            ),
            filled: true,
            fillColor: colors.surface,
          ),
        ),
      ],
    );
  }
}
