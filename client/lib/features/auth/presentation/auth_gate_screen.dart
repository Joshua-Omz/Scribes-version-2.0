import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../application/auth_notifier.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  bool _isLogin = true;
  
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  void _submit() async {
    final notifier = ref.read(authProvider.notifier);
    
    try {
      if (_isLogin) {
        await notifier.login(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        await notifier.register(
          email: _emailCtrl.text,
          handle: _handleCtrl.text,
          displayName: _nameCtrl.text,
          password: _passwordCtrl.text,
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _handleCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  colors.background.computeLuminance() > 0.5 
                      ? 'assets/app_icon.png' 
                      : 'assets/app_icon_dark.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Welcome back.' : 'Join Scribes.',
                  style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? 'Log in to continue building your sacred library.' 
                    : 'Create an account to join the conversation.',
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(ScribesRadius.button),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = true),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isLogin ? colors.surfaceRaised : Colors.transparent,
                              borderRadius: BorderRadius.circular(ScribesRadius.button - 2),
                              boxShadow: _isLogin ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Log in', 
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: _isLogin ? colors.primaryText : colors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isLogin = false),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isLogin ? colors.surfaceRaised : Colors.transparent,
                              borderRadius: BorderRadius.circular(ScribesRadius.button - 2),
                              boxShadow: !_isLogin ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sign up', 
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: !_isLogin ? colors.primaryText : colors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                if (!_isLogin) ...[
                  _buildInput('Handle', _handleCtrl, colors),
                  const SizedBox(height: 16),
                  _buildInput('Display Name', _nameCtrl, colors),
                  const SizedBox(height: 16),
                ],
                _buildInput('Email', _emailCtrl, colors, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildInput('Password', _passwordCtrl, colors, obscureText: true),
                
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.gold,
                    foregroundColor: colors.surfaceRaised,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScribesRadius.button),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: ScribesLoadingIndicator(size: 20))
                    : Text(_isLogin ? 'Log in' : 'Create Account', style: ScribesTextStyles.labelLg),
                ),
                
                if (authState.hasError) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ScribesRadius.card),
                      border: Border.all(color: colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      (authState.error is ApiException) 
                          ? (authState.error as ApiException).message 
                          : authState.error.toString(),
                      style: ScribesTextStyles.caption.copyWith(color: colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                if (_isLogin)
                  Center(
                    child: TextButton(
                      onPressed: () {}, // Forgot password
                      child: Text(
                        'Forgot password?',
                        style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, dynamic colors, {bool obscureText = false, TextInputType? keyboardType}) {
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
          obscureText: obscureText,
          keyboardType: keyboardType,
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
