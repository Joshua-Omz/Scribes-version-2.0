import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_ornament_divider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
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
