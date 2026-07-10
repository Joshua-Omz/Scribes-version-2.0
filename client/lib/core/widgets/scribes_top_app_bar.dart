import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';

import 'scribes_icon_button.dart';

class ScribesTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ScribesTopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
      ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              Expanded(
                child: Center(
                  child: Text(
                    'Scribes',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  ScribesIconButton(
                    icon: Icons.notifications_none_outlined,
                    onPressed: () {},
                    color: colors.secondaryText,
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
