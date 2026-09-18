import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../theme/scribes_radius.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import 'scribes_image_resolver.dart';
import 'scribes_scripture_chip.dart';
import '../../features/posts/domain/scripture_ref.dart';

class ScribesReflectionCard extends ConsumerWidget {
  final String bodyText;
  final String authorName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final DateTime? publishedAt;
  final String? imageUrl;
  final List<ScriptureRef> scriptureRefs;
  final List<String> tags;
  final int amenCount;
  final int insightCount;
  final int thoughtProvokingCount;
  final int commentCount;
  final String? userReactionType;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onComment;
  final void Function(String)? onReact;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onShare;
  final bool isExploreScreen;

  const ScribesReflectionCard({
    super.key,
    required this.bodyText,
    required this.authorName,
    required this.authorHandle,
    this.authorAvatarUrl,
    this.publishedAt,
    this.imageUrl,
    this.scriptureRefs = const [],
    this.tags = const [],
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    this.userReactionType,
    this.isSaved = false,
    this.onTap,
    this.onAuthorTap,
    this.onComment,
    this.onReact,
    this.onSaveToggle,
    this.onShare,
    this.isExploreScreen = false,
  });

  String _formatTimestamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    }
    return DateFormat('MMM d, y').format(date);
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.8,
            maxScale: 3.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ScribesImageResolver.buildImage(
                imageUrl: url,
                fit: BoxFit.contain,
                memCacheWidth: 1200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final resolvedImageUrl = ScribesImageResolver.resolveUrl(imageUrl);

    return InkWell(
      onTap: onTap,
      splashColor: colors.gold.withValues(alpha: 0.05),
      highlightColor: colors.gold.withValues(alpha: 0.03),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isExploreScreen ? 16 : 14,
          vertical: isExploreScreen ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: isExploreScreen ? colors.surface : Colors.transparent,
          borderRadius: isExploreScreen
              ? BorderRadius.circular(ScribesRadius.card)
              : BorderRadius.zero,
          border: isExploreScreen ? Border.all(color: colors.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 0. Contemplation Badge Row (Separate from Author Header) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedQuillWrite02,
                      color: colors.gold,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reflection',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 1. Author Header Row (Full Row Width) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Author Avatar
                GestureDetector(
                  onTap: onAuthorTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: ClipOval(
                      child: authorAvatarUrl != null &&
                              authorAvatarUrl!.trim().isNotEmpty
                          ? ScribesImageResolver.buildImage(
                              imageUrl: authorAvatarUrl,
                              fit: BoxFit.cover,
                              memCacheWidth: 120,
                              memCacheHeight: 120,
                              fallback: _buildAvatarFallback(colors),
                            )
                          : _buildAvatarFallback(colors),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name & Handle & Time
                Expanded(
                  child: GestureDetector(
                    onTap: onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                authorName.isNotEmpty
                                    ? authorName
                                    : authorHandle,
                                style: ScribesTextStyles.labelLg.copyWith(
                                  color: colors.primaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '@$authorHandle',
                                style: ScribesTextStyles.labelSm.copyWith(
                                  color: colors.secondaryText,
                                  fontSize: 12.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (publishedAt != null) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  '·',
                                  style: TextStyle(
                                    color: colors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTimestamp(publishedAt),
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.secondaryText,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Share / Overflow Menu
                if (onShare != null)
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreHorizontal,
                      color: colors.secondaryText,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    splashRadius: 16,
                    onPressed: onShare,
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // --- 2. Full Reflection Body Text ---
            if (bodyText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                child: Text(
                  bodyText,
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.primaryText,
                    fontSize: 15.5,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
              ),

            // --- 3. Attached Scripture Reference Pill ---
            if (scriptureRefs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: scriptureRefs.map((ref) {
                    final refStr = ref.verseEnd != null &&
                            ref.verseEnd != ref.verseStart
                        ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                        : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                    return ScribesScriptureChip(reference: refStr);
                  }).toList(),
                ),
              ),

            // --- 4. Attached Reflection Photo ---
            if (resolvedImageUrl != null && resolvedImageUrl.isNotEmpty)
              Builder(builder: (context) {
                final displayW = MediaQuery.sizeOf(context).width - (isExploreScreen ? 32.0 : 28.0);
                final displayH = displayW * (9 / 16);
                final cacheW = ScribesImageResolver.computeCacheWidth(
                  context,
                  displayW,
                  maxPixels: 720,
                );

                return Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: GestureDetector(
                    onTap: () => _showImageDialog(context, resolvedImageUrl),
                    child: SizedBox(
                      width: displayW,
                      height: displayH,
                      child: RepaintBoundary(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ColoredBox(color: colors.surfaceRaised),
                              ScribesImageResolver.buildImage(
                                imageUrl: resolvedImageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: cacheW,
                                placeholder: (context, url) => ColoredBox(
                                  color: colors.surfaceRaised,
                                ),
                                fallback: ColoredBox(
                                  color: colors.surfaceRaised,
                                ),
                              ),
                              IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.border.withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

            // --- 4.5 Clickable Tags ---
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags
                      .map(
                        (tag) => GestureDetector(
                          onTap: () => context.push('/tags/$tag'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                ScribesRadius.chip,
                              ),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: ScribesTextStyles.labelSm.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            // --- 5. Liturgical Tweet-Style Micro Reaction Bar ---
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amen button
                  _buildReactionButton(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    count: amenCount,
                    isActive: userReactionType == 'amen',
                    activeColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('amen'),
                  ),

                  // Insightful button
                  _buildReactionButton(
                    icon: HugeIcons.strokeRoundedBulb,
                    count: insightCount,
                    isActive: userReactionType == 'insightful',
                    activeColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('insightful'),
                  ),

                  // Deep / Thought-Provoking button
                  _buildReactionButton(
                    icon: HugeIcons.strokeRoundedDroplet,
                    count: thoughtProvokingCount,
                    isActive: userReactionType == 'thought_provoking',
                    activeColor: colors.orange,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('thought_provoking'),
                  ),

                  // Comment button
                  _buildActionButton(
                    icon: HugeIcons.strokeRoundedComment01,
                    count: commentCount,
                    color: colors.secondaryText,
                    onTap: onComment,
                  ),

                  // Save / Bookmark button
                  IconButton(
                    icon: HugeIcon(
                      icon: isSaved
                          ? HugeIcons.strokeRoundedBookmark02
                          : HugeIcons.strokeRoundedBookmark01,
                      color: isSaved ? colors.gold : colors.secondaryText,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 18,
                    onPressed: onSaveToggle,
                  ),

                  // Share button
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedShare01,
                      color: colors.secondaryText,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 18,
                    onPressed: onShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic colors) {
    final initials = authorName.trim().isNotEmpty
        ? authorName.trim().substring(0, 1).toUpperCase()
        : (authorHandle.trim().isNotEmpty
            ? authorHandle.trim().substring(0, 1).toUpperCase()
            : 'S');
    return Container(
      color: colors.surfaceRaised,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: colors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildReactionButton({
    required dynamic icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required Color defaultColor,
    required VoidCallback onTap,
  }) {
    final color = isActive ? activeColor : defaultColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: color,
              size: 20,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: ScribesTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required dynamic icon,
    required int count,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: color,
              size: 20,
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: ScribesTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
