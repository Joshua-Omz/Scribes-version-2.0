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

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final notificationsAsync = ref.watch(notificationProvider);
    final repo = ref.watch(notificationRepositoryProvider);
    final isSelectionMode = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: isSelectionMode
            ? IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: colors.primaryText),
                onPressed: _clearSelection,
              )
            : IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          isSelectionMode ? '${_selectedIds.length} Selected' : 'Notifications',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        actions: [
          if (isSelectionMode) ...[
            ScribesIconButton(
              icon: HugeIcons.strokeRoundedCheckmarkBadge01,
              onPressed: () {
                final allIds = <String>[];
                if (notificationsAsync.value != null) {
                  final items = notificationsAsync.value!;
                  final grouped = repo.groupByTime(items);
                  for (var groupItems in grouped.values) {
                    for (var n in groupItems) {
                      final id = n.id ?? n.refId.toString();
                      if (_selectedIds.contains(id)) {
                        allIds.addAll(n.safeIds);
                      }
                    }
                  }
                }
                if (allIds.isNotEmpty) {
                  ref.read(notificationProvider.notifier).markSelectedRead(allIds).then((_) {
                    _clearSelection();
                  }).catchError((e) {
                    debugPrint('Error marking read: $e');
                    _clearSelection();
                  });
                } else {
                  _clearSelection();
                }
              },
              color: colors.secondaryText,
            ),
            ScribesIconButton(
              icon: HugeIcons.strokeRoundedDelete01,
              onPressed: () {
                final allIds = <String>[];
                if (notificationsAsync.value != null) {
                  final items = notificationsAsync.value!;
                  final grouped = repo.groupByTime(items);
                  for (var groupItems in grouped.values) {
                    for (var n in groupItems) {
                      final id = n.id ?? n.refId.toString();
                      if (_selectedIds.contains(id)) {
                        allIds.addAll(n.safeIds);
                      }
                    }
                  }
                }
                if (allIds.isNotEmpty) {
                  ref.read(notificationProvider.notifier).deleteSelected(allIds).then((_) {
                    _clearSelection();
                  }).catchError((e) {
                    debugPrint('Error deleting: $e');
                    _clearSelection();
                  });
                } else {
                  _clearSelection();
                }
              },
              color: Colors.red,
            ),
          ] else ...[
            PopupMenuButton<String>(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVerticalCircle01, color: colors.secondaryText),
              color: colors.surface,
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  ref.read(notificationProvider.notifier).markAllRead();
                } else if (value == 'clear_all') {
                  ref.read(notificationProvider.notifier).clearAll();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'mark_all_read',
                  child: Text('Mark all as read', style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText)),
                ),
                PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Text('Clear all', style: ScribesTextStyles.bodyMd.copyWith(color: Colors.red)),
                ),
              ],
            ),
          ],
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
                    ...groupItems.map((n) {
                      final id = n.id ?? n.refId.toString(); // Fallback for grouped rows without a single id
                      return NotificationRow(
                        notification: n,
                        isSelectionMode: isSelectionMode,
                        isSelected: _selectedIds.contains(id),
                        onTap: () => _toggleSelection(id),
                        onLongPress: () => _toggleSelection(id),
                      );
                    }),
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
