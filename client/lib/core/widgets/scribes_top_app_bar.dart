import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/presentation/notification_badge.dart';

import 'scribes_icon_button.dart';

class ScribesTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ScribesTopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.8),
          ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                    return ScribesIconButton(
                      icon: HugeIcons.strokeRoundedMenu01,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      color: colors.secondaryText,
                    );
                  } else {
                    return const SizedBox(width: 40); // Placeholder for balance
                  }
                },
              ),
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
                  NotificationBadge(
                    child: ScribesIconButton(
                      icon: HugeIcons.strokeRoundedNotification01,
                      onPressed: () {
                        context.push('/notifications');
                      },
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
