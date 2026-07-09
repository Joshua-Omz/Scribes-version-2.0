import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import 'scribes_icon_button.dart';

class ScribesTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ScribesTopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildThemeSwitcher(ref, colors),
              Expanded(
                child: Center(
                  child: Text(
                    'SCRIBES',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              ScribesIconButton(
                icon: Icons.notifications_none_outlined,
                onPressed: () {},
                color: colors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher(WidgetRef ref, ScribesColors currentTheme) {
    return InkWell(
      onTap: () {
        // Cycle themes
        if (currentTheme == ScribesColors.light) {
          ref.read(themeProvider.notifier).setTheme(ScribesColors.dark);
        } else if (currentTheme == ScribesColors.dark) {
          ref.read(themeProvider.notifier).setTheme(ScribesColors.night);
        } else if (currentTheme == ScribesColors.night) {
          ref.read(themeProvider.notifier).setTheme(ScribesColors.parchment);
        } else if (currentTheme == ScribesColors.parchment) {
          ref.read(themeProvider.notifier).setTheme(ScribesColors.silver);
        } else {
          ref.read(themeProvider.notifier).setTheme(ScribesColors.light);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentTheme.surfaceRaised,
          border: Border.all(color: currentTheme.border),
        ),
        child: Center(
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentTheme.gold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
