import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../auth/application/auth_notifier.dart';

class EmailPasswordScreen extends ConsumerStatefulWidget {
  const EmailPasswordScreen({super.key});

  @override
  ConsumerState<EmailPasswordScreen> createState() => _EmailPasswordScreenState();
}

class _EmailPasswordScreenState extends ConsumerState<EmailPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailLoading = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    final password = _emailPasswordController.text.trim();
    final colors = ref.read(themeProvider);

    if (email.isEmpty || password.isEmpty) {
      ScribesToast.show(context, 'Both fields are required', colors, isError: true);
      return;
    }

    setState(() => _isEmailLoading = true);
    try {
      await ref.read(authProvider.notifier).updateEmail(
            newEmail: email,
            currentPassword: password,
          );
      if (mounted) {
        ScribesToast.show(context, 'Email updated successfully', colors);
        _emailPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(context, e.toString(), colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final colors = ref.read(themeProvider);

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScribesToast.show(context, 'All fields are required', colors, isError: true);
      return;
    }

    if (newPass != confirm) {
      ScribesToast.show(context, 'New passwords do not match', colors, isError: true);
      return;
    }

    setState(() => _isPasswordLoading = true);
    try {
      await ref.read(authProvider.notifier).updatePassword(
            currentPassword: current,
            newPassword: newPass,
          );
      if (mounted) {
        ScribesToast.show(context, 'Password updated successfully', colors);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScribesToast.show(context, e.toString(), colors, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPasswordLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Security', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          _buildSectionHeader('Update Email', colors),
          const SizedBox(height: 16),
          ScribesTextField(
            controller: _emailController,
            labelText: 'New Email Address',
            hintText: 'email@example.com',
            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: colors.secondaryText, size: 20),
          ),
          const SizedBox(height: 16),
          ScribesTextField(
            controller: _emailPasswordController,
            labelText: 'Current Password',
            hintText: 'To verify it\'s you',
            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLockKey, color: colors.secondaryText, size: 20),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _buildSaveButton('Update Email', _isEmailLoading, _updateEmail, colors),
          
          const SizedBox(height: 48),
          
          _buildSectionHeader('Change Password', colors),
          const SizedBox(height: 16),
          ScribesTextField(
            controller: _currentPasswordController,
            labelText: 'Current Password',
            hintText: 'Enter your old password',
            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLockKey, color: colors.secondaryText, size: 20),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ScribesTextField(
            controller: _newPasswordController,
            labelText: 'New Password',
            hintText: 'Minimum 8 characters',
            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLockKey, color: colors.secondaryText, size: 20),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ScribesTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm New Password',
            hintText: 'Must match new password',
            prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedLockKey, color: colors.secondaryText, size: 20),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _buildSaveButton('Update Password', _isPasswordLoading, _updatePassword, colors),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ScribesColors colors) {
    return Text(
      title.toUpperCase(),
      style: ScribesTextStyles.labelSm.copyWith(
        color: colors.secondaryText,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSaveButton(String text, bool isLoading, VoidCallback onPressed, ScribesColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.gold,
          foregroundColor: colors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: colors.background, strokeWidth: 2),
              )
            : Text(text, style: ScribesTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
