import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../features/posts/domain/post.dart';
import 'scribes_bounce_button.dart';
import 'scribes_avatar.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final hasImage = post.coverImageUrl != null && post.coverImageUrl!.isNotEmpty;

    return ScribesBounceButton(
      onTap: onTap ?? () => context.push('/posts/${post.id}'),
      scaleFactor: 0.98,
      child: Container(
        width: 280,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.5),
          ),
          image: hasImage 
              ? DecorationImage(
                  image: NetworkImage(post.coverImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: hasImage ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceRaised,
              colors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Dark gradient overlay for text readability when using image
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black45,
                      Colors.black87,
                    ],
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
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge
                  if (categoryLabel != null)
                    Row(
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedSparkles, color: colors.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          categoryLabel!.toUpperCase(),
                          style: ScribesTextStyles.labelSm.copyWith(
                            color: colors.gold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  
                  const Spacer(),
                  
                  // The Hero Title
                  Text(
                    post.content['title'] ?? 'Untitled',
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
                      ScribesAvatar(
                        authorName: post.authorName,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '@${post.authorHandle}',
                          style: ScribesTextStyles.labelSm.copyWith(
                            color: hasImage ? Colors.white70 : colors.secondaryText,
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
                            color: isSaved ? colors.gold : (hasImage ? Colors.white70 : colors.secondaryText),
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
    );
  }
}
