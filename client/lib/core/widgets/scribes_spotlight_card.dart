import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../features/posts/domain/post.dart';
import 'scribes_avatar.dart';
import 'scribes_image_resolver.dart';

class ScribesSpotlightCard extends ConsumerWidget {
  final Post post;
  final String? categoryLabel;
  final VoidCallback? onTap;

  const ScribesSpotlightCard({
    super.key,
    required this.post,
    this.categoryLabel,
    this.onTap,
  });

  static final Expando<String> _titleCache = Expando<String>('spotlight_title_cache');

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

    String? scriptureText;
    if (post.scriptureRefs.isNotEmpty) {
      final ref0 = post.scriptureRefs.first;
      scriptureText = '${ref0.book} ${ref0.chapter}:${ref0.verseStart}';
    }

    return GestureDetector(
      onTap: onTap ?? () => context.push('/posts/${post.id}'),
      child: Container(
        width: 290,
        height: 215,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.5),
            width: 0.7,
          ),
          color: colors.surfaceRaised,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image or Ambient Glow
            if (hasImage)
              Positioned.fill(
                child: ScribesImageResolver.buildImage(
                  imageUrl: displayImageUrl,
                  memCacheWidth: 600,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: colors.surfaceRaised),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.surfaceRaised, colors.background],
                      ),
                    ),
                  ),
                  fallback: Container(color: colors.surfaceRaised),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.surfaceRaised,
                        colors.background,
                      ],
                    ),
                  ),
                ),
              ),

            // Single smooth gradient overlay for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.65),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category Tag & Scripture
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (categoryLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colors.gold.withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedSparkles,
                                color: colors.gold,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                categoryLabel!.toUpperCase(),
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.gold,
                                  fontSize: 10,
                                  letterSpacing: 0.9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (scriptureText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scriptureText,
                            style: ScribesTextStyles.caption.copyWith(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // Manuscript Title
                  Text(
                    title,
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Author & Amen / Insight counts
                  Row(
                    children: [
                      ScribesAvatar(
                        authorName: post.authorName,
                        radius: 11,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '@${post.authorHandle}',
                          style: ScribesTextStyles.caption.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.amenCount > 0) ...[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedFire,
                          color: Colors.white60,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${post.amenCount}',
                          style: ScribesTextStyles.caption.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (post.insightCount > 0) ...[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSparkles,
                          color: colors.gold,
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
          ],
        ),
      ),
    );
  }
}
