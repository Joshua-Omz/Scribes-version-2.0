import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/features/posts/application/post_detail_provider.dart';
import 'package:go_router/go_router.dart';

class VersionHistorySheet extends ConsumerWidget {
  final String postId;

  const VersionHistorySheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VersionHistorySheet(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    final state = ref.watch(postDetailProvider(postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Version History', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                IconButton(
                  icon: Icon(Icons.close, color: colors.primaryText),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          Expanded(
            child: state.when(
              data: (data) {
                final versions = data.versions;
                if (versions.isEmpty) {
                  return Center(
                    child: Text('No previous versions found.', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
                  );
                }

                return ListView.separated(
                  itemCount: versions.length,
                  separatorBuilder: (context, index) => Divider(color: colors.border, height: 1),
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    return ListTile(
                      title: Text('Version ${version.versionNumber}', style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
                      subtitle: Text('Saved on ${version.snapshottedAt.toLocal().toString().split('.')[0]}', style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText)),
                      trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
                      onTap: () {
                        // TODO: Navigate to diff view or specific version
                      },
                    );
                  },
                );
              },
              loading: () => Center(child: ScribesLoadingIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
