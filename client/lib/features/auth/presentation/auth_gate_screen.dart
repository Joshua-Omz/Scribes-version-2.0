import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../application/auth_notifier.dart';
import '../domain/user.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  bool _isLogin = true;
  
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordCtrl2 = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePassword2 = true;

  void _submit() {
    final notifier = ref.read(authProvider.notifier);
    
    if (_isLogin) {
      notifier.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    } else {
      if (_passwordCtrl.text != _passwordCtrl2.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords don't match")),
        );
        return;
      }
      notifier.register(
        email: _emailCtrl.text,
        handle: _handleCtrl.text,
        displayName: _nameCtrl.text,
        password: _passwordCtrl.text,
      );
    }
  }

  void _signInWithGoogle() async {
    final notifier = ref.read(authProvider.notifier);
    
    try {
      debugPrint('Starting Google Sign-In...');
      final googleUser = await GoogleSignIn.instance.authenticate();
      debugPrint('googleUser returned: \$googleUser');
      
      final googleAuth = googleUser.authentication;
      debugPrint('googleAuth retrieved. idToken is null? \${googleAuth.idToken == null}');
      
      if (googleAuth.idToken != null) {
        debugPrint('Calling backend with idToken...');
        notifier.loginWithGoogle(googleAuth.idToken!);
      } else {
        debugPrint('ERROR: idToken is null! Check Google Cloud console SHA-1 and Client ID config.');
      }
    } catch (e) {
      debugPrint('Google Sign-In exception: \$e\\n\$stack');
      if (mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(context, 'Google Sign-In failed: $e', colors, isError: true);
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

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (next is AsyncError) {
        final error = next.error;
        String message = error.toString();
        
        // Extract inner ApiException message if wrapped by DioException
        if (error is DioException && error.error is ApiException) {
          message = (error.error as ApiException).message;
        } else if (error is ApiException) {
          message = error.message;
        }

        ScribesToast.show(context, message, colors, isError: true);
      }
    });

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
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 120,
                  height: 120,
                  colorFilter: ColorFilter.mode(colors.gold, BlendMode.srcIn),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _isLogin = true),
                            borderRadius: BorderRadius.circular(ScribesRadius.button - 2),
                            splashColor: colors.gold.withValues(alpha: 0.1),
                            highlightColor: colors.gold.withValues(alpha: 0.05),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                      ),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _isLogin = false),
                            borderRadius: BorderRadius.circular(ScribesRadius.button - 2),
                            splashColor: colors.gold.withValues(alpha: 0.1),
                            highlightColor: colors.gold.withValues(alpha: 0.05),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                if (!_isLogin) ...[
                  ScribesTextField(labelText: 'Handle', controller: _handleCtrl),
                  const SizedBox(height: 16),
                  ScribesTextField(labelText: 'Display Name', controller: _nameCtrl),
                  const SizedBox(height: 16),
                ],
                ScribesTextField(labelText: 'Email', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                ScribesTextField(
                  labelText: 'Password', 
                  controller: _passwordCtrl, 
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: colors.secondaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  ScribesTextField(
                    labelText: "Re-enter Password", 
                    controller: _passwordCtrl2, 
                    obscureText: _obscurePassword2,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword2 ? Icons.visibility_off : Icons.visibility,
                        color: colors.secondaryText,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                    ),
                  ),
                ],
                
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.surfaceRaised,
                    foregroundColor: colors.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScribesRadius.button),
                      side: BorderSide(color: colors.border),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _signInWithGoogle,
                  icon: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    width: 20,
                    height: 20,
                  ),
                  label: Text('Continue with Google', style: ScribesTextStyles.labelLg),
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
                      _getCleanErrorMessage(authState.error),
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

  String _getCleanErrorMessage(Object? error) {
    if (error == null) return 'Unknown error';
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    } else if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}
