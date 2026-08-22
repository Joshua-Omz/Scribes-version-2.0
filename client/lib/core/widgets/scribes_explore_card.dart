import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../features/posts/domain/post.dart';
import 'scribes_avatar.dart';
import 'scribes_image_resolver.dart';

class ScribesExploreCard extends ConsumerWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;
  final bool isSaved;
  final String? categoryLabel;

  const ScribesExploreCard({
    super.key,
    required this.post,
    this.onTap,
    this.onSaveToggle,
    this.isSaved = false,
    this.categoryLabel,
  });

  String _extractTitle(Map<String, dynamic> content) {
    if (content['title'] != null &&
        content['title'].toString().trim().isNotEmpty) {
      return content['title'].toString().trim();
    }
    final ops = content['ops'] ?? content['body'];
    if (ops is List) {
      for (final op in ops) {
        if (op is Map && op['insert'] is String) {
          final text = op['insert'].toString().trim();
          if (text.isNotEmpty) {
            return text.split('\n').first;
          }
        }
      }
    }
    return 'Untitled';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final String? displayImageUrl = ScribesImageResolver.extractFirstImageUrl(
      post,
    );
    final hasImage = displayImageUrl != null && displayImageUrl.isNotEmpty;
    final title = _extractTitle(post.content);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/posts/${post.id}'),
      child: Container(
        width: 280,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
          color: colors.surfaceRaised,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image with ScribesImageResolver or Ambient Gradient
              if (hasImage)
                Positioned.fill(
                  child: ScribesImageResolver.buildImage(
                    imageUrl: displayImageUrl,
                    memCacheWidth: 800,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: colors.surfaceRaised),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.surfaceRaised, colors.background],
                        ),
                      ),
                    ),
                    fallback: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.surfaceRaised, colors.background],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.surfaceRaised, colors.background],
                      ),
                    ),
                  ),
                ),

              // Dark gradient overlay for text readability when using image
              if (hasImage)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.black87],
                      ),
                    ),
                  ),
                ),

              // Ambient watermark icon if no image
              if (!hasImage)
                Positioned(
                  right: -30,
                  bottom: 20,
                  child: Opacity(
                    opacity: 0.04,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedChurch,
                      color: colors.primaryText,
                      size: 200,
                    ),
                  ),
                ),

              // Card Content Overlay
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top badge
                    if (categoryLabel != null)
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedSparkles,
                            color: colors.gold,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            categoryLabel!.toUpperCase(),
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.gold,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // The Hero Title
                    Text(
                      title,
                      style: ScribesTextStyles.displayLg.copyWith(
                        color: hasImage ? Colors.white : colors.primaryText,
                        height: 1.15,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Bottom Bar (Author & Action)
                    Row(
                      children: [
                        ScribesAvatar(authorName: post.authorName, radius: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '@${post.authorHandle}',
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: hasImage
                                  ? Colors.white70
                                  : colors.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onSaveToggle != null)
                          IconButton(
                            onPressed: onSaveToggle,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedBookmark01,
                              color: isSaved
                                  ? colors.gold
                                  : (hasImage
                                        ? Colors.white70
                                        : colors.secondaryText),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
