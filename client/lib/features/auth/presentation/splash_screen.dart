import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';

/// Purely visual splash screen.
///
/// Navigation is handled entirely by GoRouter's redirect, which listens to
/// [authProvider] via [refreshListenable]. When auth state resolves from
/// AsyncLoading → AsyncData, the redirect fires and routes the user to
/// either '/' (authenticated) or '/auth' (unauthenticated).
///
/// Previous implementation had a hardcoded 2-second Future.delayed + context.go('/')
/// that raced the auth state — if GET /me took >2s (slow network, cold start),
/// users landed on the feed without a token and every API call 401'd.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              width: 120,
              height: 120,
              colorFilter: ColorFilter.mode(colors.gold, BlendMode.srcIn),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: ScribesOrnamentDivider(),
            ),
            const SizedBox(height: 16),
            Text(
              '2 Timothy 3:16-17   •   Acts 26:28',
              style: ScribesTextStyles.labelLg.copyWith(
                color: colors.secondaryText,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
