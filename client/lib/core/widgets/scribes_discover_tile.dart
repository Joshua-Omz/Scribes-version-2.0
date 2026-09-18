import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../features/posts/domain/post.dart';
import 'scribes_avatar.dart';
import 'scribes_image_resolver.dart';

class ScribesDiscoverTile extends ConsumerWidget {
  final Post post;
  final String? categoryLabel;
  final VoidCallback? onTap;

  const ScribesDiscoverTile({
    super.key,
    required this.post,
    this.categoryLabel,
    this.onTap,
  });

  static final Expando<String> _titleCache = Expando<String>('discover_title_cache');

  static String _extractTitle(Post post) {
    final cached = _titleCache[post];
    if (cached != null) return cached;

    final content = post.content;
    String title = 'Untitled';
    if (content['title'] != null && content['title'].toString().trim().isNotEmpty) {
      title = content['title'].toString().trim();
    } else {
      final ops = content['ops'] ?? content['body'];
      if (ops is List) {
        for (final op in ops) {
          if (op is Map && op['insert'] is String) {
            final text = op['insert'].toString().trim();
            if (text.isNotEmpty) {
              title = text.split('\n').first;
              break;
            }
          }
        }
      }
    }
    _titleCache[post] = title;
    return title;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final title = _extractTitle(post);
    final String? displayImageUrl = ScribesImageResolver.extractFirstImageUrl(post);
    final hasImage = displayImageUrl != null && displayImageUrl.isNotEmpty;

    // First scripture reference formatted if present
    String? scriptureText;
    if (post.scriptureRefs.isNotEmpty) {
      final ref0 = post.scriptureRefs.first;
      scriptureText = '${ref0.book} ${ref0.chapter}:${ref0.verseStart}';
    }

    final excerpt = post.plainTextBody;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.push('/posts/${post.id}'),
        borderRadius: BorderRadius.circular(14),
        splashColor: colors.gold.withValues(alpha: 0.08),
        highlightColor: colors.surfaceRaised.withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.border.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Metadata Row: Category / Scripture badge
                    Row(
                      children: [
                        if (categoryLabel != null && categoryLabel!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              categoryLabel!.toUpperCase(),
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.gold,
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (scriptureText != null) ...[
                          Text(
                            scriptureText,
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Manuscript Title
                    Text(
                      title,
                      style: ScribesTextStyles.displayMd.copyWith(
                        color: colors.primaryText,
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (excerpt.isNotEmpty && excerpt != title) ...[
                      const SizedBox(height: 4),
                      Text(
                        excerpt,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Author & Telemetry Footer Row
                    Row(
                      children: [
                        ScribesAvatar(
                          authorName: post.authorName,
                          radius: 10,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '@${post.authorHandle}',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Amen count
                        if (post.amenCount > 0) ...[
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedFire,
                            color: colors.secondaryText.withValues(alpha: 0.7),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${post.amenCount}',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Insight count
                        if (post.insightCount > 0) ...[
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedSparkles,
                            color: colors.gold.withValues(alpha: 0.8),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${post.insightCount}',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.gold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Right Thumbnail Image (Downsampled for 60-120fps memory efficiency)
              if (hasImage) ...[
                const SizedBox(width: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: RepaintBoundary(
                      child: ScribesImageResolver.buildImage(
                        imageUrl: displayImageUrl,
                        memCacheWidth: 280,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ColoredBox(
                          color: colors.surfaceRaised,
                        ),
                        errorWidget: (context, url, error) => ColoredBox(
                          color: colors.surfaceRaised,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 18,
                            color: colors.secondaryText,
                          ),
                        ),
                        fallback: ColoredBox(
                          color: colors.surfaceRaised,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
