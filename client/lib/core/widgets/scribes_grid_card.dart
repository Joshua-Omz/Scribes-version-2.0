import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';
import 'scribes_bounce_button.dart';

class ScribesGridCard extends ConsumerWidget {
  final String title;
  final String excerpt;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? badgeText;
  final bool isSaved;
  final bool isSelected;
  final bool isDeleted;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onDelete;

  const ScribesGridCard({
    super.key,
    required this.title,
    required this.excerpt,
    this.date,
    required this.onTap,
    this.onLongPress,
    this.badgeText,
    this.isSaved = false,
    this.isSelected = false,
    this.isDeleted = false,
    this.onSaveToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final hasBadge = badgeText != null;

    return ScribesBounceButton(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasBadge ? colors.background : colors.surfaceRaised,
              borderRadius: BorderRadius.circular(ScribesRadius.card),
              border: Border.all(
                color: isSelected 
                  ? colors.gold 
                  : colors.border.withValues(alpha: hasBadge ? 0.3 : 0.6),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: hasBadge
                  ? []
                  : [
                      BoxShadow(
                        color: colors.border.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Badge, Save Icon, Delete Icon)
                if (hasBadge || isSaved || onDelete != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (hasBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.goldMuted.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(ScribesRadius.chip),
                              border: Border.all(
                                color: colors.goldMuted.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              badgeText!.toUpperCase(),
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.gold,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(), // Spacer
                        Row(
                          children: [
                            if (isSaved)
                              GestureDetector(
                                onTap: onSaveToggle,
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookmark02,
                                  color: colors.gold,
                                  size: 18,
                                ),
                              ),
                            if (isSaved && onDelete != null) const SizedBox(width: 8),
                            if (onDelete != null)
                              GestureDetector(
                                onTap: onDelete,
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete02,
                                  color: Colors.red.shade400,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (isDeleted)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            color: colors.secondaryText,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This post has been deleted',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Title
                  Text(
                    title.isEmpty ? 'Untitled' : title,
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontSize: 18,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Excerpt (Faded out at bottom)
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black,
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Text(
                        excerpt.isEmpty ? 'No excerpt' : excerpt,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],

                // Date Footer
                if (date != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      timeago.format(date!),
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colors.gold,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 16, color: colors.surfaceRaised),
              ),
            ),
        ],
      ),
    );
  }
}

