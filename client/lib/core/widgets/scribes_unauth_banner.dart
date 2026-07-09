import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';
import 'scribes_ornament_divider.dart';

class ScribesUnauthBanner extends ConsumerWidget {
  final VoidCallback onJoinTap;
  final VoidCallback onLoginTap;

  const ScribesUnauthBanner({
    super.key,
    required this.onJoinTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScribesOrnamentDivider(),
            const SizedBox(height: 16),
            Text(
              'Join Scribes',
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to join the conversation and build your sacred library.',
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                    ),
                    onPressed: onLoginTap,
                    child: Text('Log in', style: ScribesTextStyles.labelLg),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surfaceRaised,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onJoinTap,
                    child: Text('Sign up', style: ScribesTextStyles.labelLg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
