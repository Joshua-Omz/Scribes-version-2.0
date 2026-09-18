import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';
import '../theme/scribes_colors.dart';

/// Monastic branch sheet for navigating between Personal Study Notes and Manuscript Drafts.
class ScribesNotesBranchSheet extends ConsumerWidget {
  const ScribesNotesBranchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => const ScribesNotesBranchSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(ScribesRadius.sheet),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: colors.glassBlur,
          sigmaY: colors.glassBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ScribesRadius.sheet),
            ),
            border: Border(
              top: BorderSide(
                color: colors.border.withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.secondaryText.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workspace',
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your journal space or publication manuscripts',
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Branch Option 1: Study Notes
                  _buildBranchOption(
                    context: context,
                    colors: colors,
                    icon: HugeIcons.strokeRoundedBook01,
                    title: 'Study Notes',
                    subtitle:
                        'Personal scripture journaling, study notes & notebooks',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/notes');
                    },
                  ),

                  const SizedBox(height: 12),

                  // Branch Option 2: Manuscript Drafts
                  _buildBranchOption(
                    context: context,
                    colors: colors,
                    icon: HugeIcons.strokeRoundedFileEdit,
                    title: 'Manuscript Drafts',
                    subtitle:
                        'Unpublished post drafts, reflections & manuscripts',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drafts');
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchOption({
    required BuildContext context,
    required ScribesColors colors,
    required dynamic icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScribesRadius.card),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.gold.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: HugeIcon(
                icon: icon,
                color: colors.gold,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ScribesTextStyles.labelLg.copyWith(
                      color: colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.secondaryText,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: colors.secondaryText.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
