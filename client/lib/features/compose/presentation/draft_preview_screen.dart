import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../posts/presentation/widgets/post_rich_text.dart';
import '../application/compose_provider.dart';

class DraftPreviewScreen extends ConsumerWidget {
  const DraftPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(composeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        title: Text(
          'Preview',
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.push('/compose/publish');
            },
            child: Text(
              'Next: Add Details',
              style: ScribesTextStyles.labelLg.copyWith(color: colors.gold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: colors.background,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.title.isNotEmpty ? state.title : 'Untitled',
                style: ScribesTextStyles.displayXl.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 24),
              if (state.contentDelta != null)
                PostRichText(content: state.contentDelta!)
              else
                Text(
                  'No content written yet.',
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // If we came from feed directly, we push editor. If we came from editor, we pop.
          // Let's just push or replace to editor.
          context.push('/compose');
        },
        backgroundColor: colors.surfaceRaised,
        icon: Icon(Icons.edit, color: colors.primaryText),
        label: Text('Edit', style: TextStyle(color: colors.primaryText)),
      ),
    );
  }
}
