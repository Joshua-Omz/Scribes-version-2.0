import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/scribes_radius.dart';
import '../application/compose_provider.dart';

/// Redesigned Liturgical / Monastic Compose Type Selection Bottom Sheet.
/// Stripped of cardness, nested borders, and box-in-box UI.
class ComposeTypeSheet extends ConsumerWidget {
  const ComposeTypeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ComposeTypeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 0.5,
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
              // Subtle centered drag pill
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
              const SizedBox(height: 20),

              // Title & Monastic Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What would you like to create?',
                      style: ScribesTextStyles.displayMd.copyWith(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a form for your contemplation, manuscript, or teaching',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Divider(
                color: colors.border.withValues(alpha: 0.4),
                height: 1,
                thickness: 0.5,
              ),
              const SizedBox(height: 6),

              // 1. Reflection
              _buildOptionRow(
                context,
                colors: colors,
                icon: HugeIcons.strokeRoundedQuillWrite02,
                accentColor: colors.gold,
                title: 'Reflection',
                meta: 'Short-form',
                subtitle: 'A brief contemplation, verse, or prayer (under 500 chars)',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/compose/reflection');
                },
              ),

              Divider(
                color: colors.border.withValues(alpha: 0.2),
                height: 1,
                thickness: 0.5,
                indent: 64,
              ),

              // 2. Standard Post
              _buildOptionRow(
                context,
                colors: colors,
                icon: HugeIcons.strokeRoundedBookOpen01,
                accentColor: colors.primaryText,
                title: 'Standard Post',
                meta: 'Manuscript',
                subtitle: 'Full reflection, study essay, or teaching with cover image',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(composeProvider.notifier).reset();
                  context.push('/compose');
                },
              ),

              Divider(
                color: colors.border.withValues(alpha: 0.2),
                height: 1,
                thickness: 0.5,
                indent: 64,
              ),

              // 3. Passage
              _buildOptionRow(
                context,
                colors: colors,
                icon: HugeIcons.strokeRoundedLayers01,
                accentColor: colors.orange,
                title: 'Passage',
                meta: 'Devotional',
                subtitle: 'Structured, multi-panel interactive deck with ambient audio',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/compose/passage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context, {
    required dynamic colors,
    required dynamic icon,
    required Color accentColor,
    required String title,
    required String meta,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: colors.surfaceRaised.withValues(alpha: 0.5),
        splashColor: accentColor.withValues(alpha: 0.08),
        highlightColor: accentColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illuminated Icon Orb (no harsh boxes/borders)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    color: accentColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Typographic Text Info (Flexible & overflow-safe)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: ScribesTextStyles.labelLg.copyWith(
                            color: colors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· $meta',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText.withValues(alpha: 0.7),
                            fontSize: 11,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.secondaryText,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Subtle Trailing Chevron
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: colors.secondaryText.withValues(alpha: 0.35),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
