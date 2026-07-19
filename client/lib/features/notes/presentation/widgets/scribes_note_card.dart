import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../domain/note.dart';

class ScribesNoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScribesNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final dateStr = DateFormat('MMM d, yyyy').format(note.updatedAt);
    
    // Extract snippet from rich text
    String snippet = '';
    try {
      final body = note.content['body'];
      if (body is List && body.isNotEmpty) {
        final firstInsert = body.firstWhere((e) => e['insert'] is String, orElse: () => null);
        if (firstInsert != null) {
          snippet = firstInsert['insert'].toString().replaceAll('\n', ' ').trim();
        }
      }
    } catch (_) {}
    
    if (snippet.length > 100) {
      snippet = '${snippet.substring(0, 100)}...';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (note.title != null && note.title!.isNotEmpty) ? note.title! : 'Untitled Note',
                      style: ScribesTextStyles.displayMd.copyWith(
                        color: colors.primaryText,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colors.secondaryText, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: colors.surface,
                          title: Text('Delete Note?', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                          content: Text('This cannot be undone.', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: colors.primaryText)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onDelete();
                              },
                              child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
              if (snippet.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  snippet,
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.secondaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: colors.secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                  const Spacer(),
                  // Cloud synced indicator
                  Icon(
                    note.id.isEmpty ? Icons.cloud_off : Icons.cloud_done_outlined, // Simplified sync indicator
                    size: 16,
                    color: colors.secondaryText.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
