import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../application/notification_provider.dart';
import '../data/notification_repository.dart';
import 'notification_row.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final notificationsAsync = ref.watch(notificationProvider);
    final repo = ref.watch(notificationRepositoryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text('Notifications', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
        actions: [
          ScribesIconButton(
            icon: HugeIcons.strokeRoundedCheckmarkBadge01,
            onPressed: () {
              ref.read(notificationProvider.notifier).markAllRead();
            },
            color: colors.secondaryText,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colors.gold,
        backgroundColor: colors.surface,
        onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
        child: notificationsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: ScribesEmptyState(
                  icon: HugeIcons.strokeRoundedNotification01,
                  title: 'All caught up',
                  subtitle: 'You have no new notifications.',
                ),
              );
            }

            final grouped = repo.groupByTime(items);

            return ListView.builder(
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final key = grouped.keys.elementAt(index);
                final groupItems = grouped[key]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        key,
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.secondaryText,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...groupItems.map((n) => NotificationRow(notification: n)).toList(),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: ScribesLoadingIndicator()),
          error: (err, stack) => ScribesErrorState(
            title: 'Could not load notifications',
            subtitle: err.toString(),
            onRetry: () => ref.read(notificationProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
