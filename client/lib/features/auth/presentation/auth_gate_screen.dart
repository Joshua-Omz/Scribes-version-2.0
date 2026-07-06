import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Welcome back.' : 'Join Scribes.',
                  style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _isLogin = true),
                      child: Text('Login', style: ScribesTextStyles.labelLg.copyWith(
                        color: _isLogin ? colors.gold : colors.secondaryText,
                      )),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = false),
                      child: Text('Register', style: ScribesTextStyles.labelLg.copyWith(
                        color: !_isLogin ? colors.gold : colors.secondaryText,
                      )),
                    ),
                  ],
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
                
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.gold,
                    foregroundColor: colors.surfaceRaised,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScribesRadius.button),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isLogin ? 'Login' : 'Create Account', style: ScribesTextStyles.labelLg),
                ),
                
                if (authState.hasError) ...[
                  const SizedBox(height: 24),
                  Text(
                    (authState.error is ApiException) 
                        ? (authState.error as ApiException).message 
                        : authState.error.toString(),
                    style: TextStyle(color: colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, dynamic colors, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScribesRadius.input),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScribesRadius.input),
          borderSide: BorderSide(color: colors.gold),
        ),
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }
}
