import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
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
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement backend patch
              

              ScribesToast.show(context, 'Profile updated successfully!', colors);
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
                  radius: 48,
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
            const SizedBox(height: 48),
            ScribesTextField(
              labelText: 'Display Name',
              controller: _nameCtrl,
            ),
            const SizedBox(height: 24),
            ScribesTextField(
              labelText: 'Bio',
              controller: _bioCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
