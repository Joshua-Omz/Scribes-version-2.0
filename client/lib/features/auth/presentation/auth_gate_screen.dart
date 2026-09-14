import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';
import '../../../core/widgets/scribes_brand_logo.dart';
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
  bool _isChurch = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onTextChanged);
    _passwordCtrl.addListener(_onTextChanged);
    _passwordCtrl2.addListener(_onTextChanged);
    _handleCtrl.addListener(_onTextChanged);
    _nameCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _isValid {
    if (_isLogin) {
      return _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;
    } else {
      return _emailCtrl.text.trim().isNotEmpty &&
          _passwordCtrl.text.isNotEmpty &&
          _passwordCtrl2.text.isNotEmpty &&
          _handleCtrl.text.trim().isNotEmpty &&
          _nameCtrl.text.trim().isNotEmpty;
    }
  }

  void _submit() {
    final notifier = ref.read(authProvider.notifier);

    if (_isLogin) {
      notifier.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      if (_passwordCtrl.text != _passwordCtrl2.text) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(
          context,
          "Passwords do not match",
          colors,
          isError: true,
        );
        return;
      }
      notifier.register(
        email: _emailCtrl.text.trim(),
        handle: _handleCtrl.text.trim().replaceAll('@', ''),
        displayName: _nameCtrl.text.trim(),
        password: _passwordCtrl.text,
        isChurch: _isChurch,
      );
    }
  }

  void _signInWithGoogle() async {
    final notifier = ref.read(authProvider.notifier);

    try {
      debugPrint('Starting Google Sign-In...');
      final googleUser = await GoogleSignIn.instance.authenticate();
      debugPrint('googleUser returned: $googleUser');

      final googleAuth = googleUser.authentication;
      if (googleAuth.idToken != null) {
        debugPrint('Calling backend with Google idToken...');
        notifier.loginWithGoogle(googleAuth.idToken!);
      } else {
        if (mounted) {
          final colors = ref.read(themeProvider);
          ScribesToast.show(
            context,
            'Google Sign-In token unavailable. Please try again.',
            colors,
            isError: true,
          );
        }
      }
    } catch (e, stack) {
      debugPrint('Google Sign-In exception: $e\n$stack');
      if (mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(
          context,
          'Google Sign-In failed: $e',
          colors,
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordCtrl2.dispose();
    _handleCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (next is AsyncData &&
          next.value != null &&
          (previous?.value == null || previous is AsyncLoading)) {
        final user = next.value!;
        final name = user.displayName.isNotEmpty
            ? user.displayName
            : user.handle;
        final message = _isLogin
            ? 'Welcome back to the Sanctuary, $name'
            : 'Welcome to Scribes, $name';

        ScribesToast.show(
          context,
          message,
          colors,
          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
        );

        final needsOnboarding = user.selectedTags.isEmpty;
        if (needsOnboarding) {
          context.go('/onboarding');
          return;
        }

        final redirect =
            GoRouterState.of(context).uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          context.go(redirect);
          return;
        }

        context.go('/');
      }

      if (next is AsyncError) {
        final error = next.error;
        String message = error.toString();

        if (error is DioException && error.error is ApiException) {
          message = (error.error as ApiException).message;
        } else if (error is ApiException) {
          message = error.message;
        }

        ScribesToast.show(context, message, colors, isError: true);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: colors.primaryText,
              size: 22,
            ),
            tooltip: 'Back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: Text(
                'Explore as Guest',
                style: ScribesTextStyles.labelSm.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sacred Illuminated Emblem & Seal
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Radiant ambient aura glow
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  colors.gold.withValues(alpha: 0.18),
                                  colors.gold.withValues(alpha: 0.04),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          
                       ScribesBrandLogo(
                              variant: BrandLogoVariant.iconOnly,
                              size: 50,
                            ),
                       
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Motto Caption
                    Center(
                      child: Text(
                        'SCRIBES SANCTUARY',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.goldMuted,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Animated Headline & Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Column(
                        key: ValueKey<bool>(_isLogin),
                        children: [
                          Text(
                            _isLogin
                                ? 'Welcome to the Sanctuary'
                                : 'Join the Sacred Fellowship',
                            style: ScribesTextStyles.displayLg.copyWith(
                              color: colors.primaryText,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isLogin
                                ? 'Welcome Back'
                                : 'Join Us to Follow him ',
                            style: ScribesTextStyles.bodyMd.copyWith(
                              color: colors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Liturgical Ornament Divider
                    const ScribesOrnamentDivider(),
                    const SizedBox(height: 24),

                    // Segmented Log in / Sign up Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          ScribesRadius.button + 2,
                        ),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _isLogin = true),
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.button,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isLogin
                                        ? colors.surfaceRaised
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      ScribesRadius.button,
                                    ),
                                    border: _isLogin
                                        ? Border.all(
                                            color: colors.gold.withValues(
                                              alpha: 0.3,
                                            ),
                                          )
                                        : null,
                                    boxShadow: _isLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Log in',
                                    style: ScribesTextStyles.labelLg.copyWith(
                                      color: _isLogin
                                          ? colors.primaryText
                                          : colors.secondaryText,
                                      fontWeight: _isLogin
                                          ? FontWeight.w700
                                          : FontWeight.w500,
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
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.button,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isLogin
                                        ? colors.surfaceRaised
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      ScribesRadius.button,
                                    ),
                                    border: !_isLogin
                                        ? Border.all(
                                            color: colors.gold.withValues(
                                              alpha: 0.3,
                                            ),
                                          )
                                        : null,
                                    boxShadow: !_isLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Create Account',
                                    style: ScribesTextStyles.labelLg.copyWith(
                                      color: !_isLogin
                                          ? colors.primaryText
                                          : colors.secondaryText,
                                      fontWeight: !_isLogin
                                          ? FontWeight.w700
                                          : FontWeight.w500,
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

                    // Animated Form Fields
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeInOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLogin) ...[
                            ScribesTextField(
                              labelText: 'Handle',
                              controller: _handleCtrl,
                              hintText: 'e.g. john_theologian',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                child: Text(
                                  '@',
                                  style: ScribesTextStyles.labelLg.copyWith(
                                    color: colors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                            ScribesTextField(
                              labelText: 'Display Name',
                              controller: _nameCtrl,
                              hintText: 'e.g. John of Patmos',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  color: colors.secondaryText,
                                  size: 18,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                          ],

                          ScribesTextField(
                            labelText: 'Email Address',
                            controller: _emailCtrl,
                            hintText: 'scribe@sanctuary.org',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedMail01,
                                color: colors.secondaryText,
                                size: 18,
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 14),

                          ScribesTextField(
                            labelText: 'Password',
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedLockPassword,
                                color: colors.secondaryText,
                                size: 18,
                              ),
                            ),
                            textInputAction: _isLogin
                                ? TextInputAction.done
                                : TextInputAction.next,
                            onSubmitted: (_) {
                              if (_isLogin) _submit();
                            },
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: HugeIcon(
                                icon: _obscurePassword
                                    ? HugeIcons.strokeRoundedViewOffSlash
                                    : HugeIcons.strokeRoundedView,
                                color: colors.secondaryText,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          if (!_isLogin) ...[
                            const SizedBox(height: 14),
                            ScribesTextField(
                              labelText: "Confirm Password",
                              controller: _passwordCtrl2,
                              obscureText: _obscurePassword2,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedLockPassword,
                                  color: colors.secondaryText,
                                  size: 18,
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword2
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: HugeIcon(
                                  icon: _obscurePassword2
                                      ? HugeIcons.strokeRoundedViewOffSlash
                                      : HugeIcons.strokeRoundedView,
                                  color: colors.secondaryText,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword2 = !_obscurePassword2;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Ministry / Church Option Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.card,
                                ),
                                border: Border.all(
                                  color: _isChurch
                                      ? colors.gold.withValues(alpha: 0.5)
                                      : colors.border.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: _isChurch,
                                      onChanged: (value) {
                                        setState(() {
                                          _isChurch = value ?? false;
                                        });
                                      },
                                      activeColor: colors.gold,
                                      checkColor: colors.background,
                                      side: BorderSide(
                                        color: colors.border,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isChurch = !_isChurch;
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Church or Ministry Account',
                                            style: ScribesTextStyles.labelLg
                                                .copyWith(
                                                  color: colors.primaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Enables verified sermon archiving & community study features.',
                                            style: ScribesTextStyles.caption
                                                .copyWith(
                                                  color: colors.secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Primary Sacred CTA Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.primaryText,
                        side: BorderSide(color: colors.goldEdge, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScribesRadius.button + 2,
                          ),
                        ),
                      ),
                      onPressed: (authState.isLoading || !_isValid)
                          ? null
                          : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: ScribesLoadingIndicator(size: 20),
                            )
                          : Text(
                              _isLogin ? 'Enter Sanctuary' : 'Create Account',
                              style: ScribesTextStyles.labelLg.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: colors.background,
                              ),
                            ),
                    ),
                    const SizedBox(height: 18),

                    // Subtle "OR" divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colors.border.withValues(alpha: 0.5),
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colors.border.withValues(alpha: 0.5),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Google Authentication Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surfaceRaised,
                        foregroundColor: colors.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScribesRadius.button + 2,
                          ),
                          side: BorderSide(
                            color: colors.border.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      onPressed: authState.isLoading ? null : _signInWithGoogle,
                      icon: CachedNetworkImage(
                        imageUrl:
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox(
                          width: 18,
                          height: 18,
                          child: Center(
                            child: ScribesLoadingIndicator(size: 14),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.network(
                          'https://developers.google.com/identity/images/g-logo.png',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.g_mobiledata,
                            size: 20,
                            color: colors.primaryText,
                          ),
                        ),
                      ),
                      label: Text(
                        'Continue with Google',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (authState.hasError) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            ScribesRadius.card,
                          ),
                          border: Border.all(
                            color: colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _getCleanErrorMessage(authState.error),
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    if (_isLogin)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ScribesToast.show(
                              context,
                              'Password recovery instructions sent if registered.',
                              colors,
                            );
                          },
                          child: Text(
                            'Forgot password?',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCleanErrorMessage(Object? error) {
    if (error == null) return 'Unknown error occurred';
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    if (error is ApiException) return error.message;
    final str = error.toString();
    return str.replaceAll('Exception:', '').trim();
  }
}
