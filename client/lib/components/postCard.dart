import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../app_config/theme.dart';
import '../app_config/typography.dart';

enum PostCardLayout { standard, textOnly, overlay, feature }

class PostCard extends StatelessWidget {
  final Post post;
  final PostCardLayout layout;

  const PostCard({
    super.key,
    required this.post,
    this.layout = PostCardLayout.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (layout) {
      case PostCardLayout.standard:
        return _buildStandard(theme, isDark);
      case PostCardLayout.textOnly:
        return _buildTextOnly(theme, isDark);
      case PostCardLayout.overlay:
        return _buildOverlay();
      case PostCardLayout.feature:
        return _buildFeature(theme, isDark);
    }
  }

  Widget _buildStandard(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: isDark ? [] : AppTheme.standardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              'https://images.unsplash.com/photo-1455390582262-044cdead27d8?auto=format&fit=crop&w=600&q=80',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        post.category.toUpperCase(),
                        style: AppTypography.categoryLabel.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('4 min read', style: AppTypography.metaData),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  post.title,
                  style: AppTypography.articleTitle
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8.0),
                Text(
                  post.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyText,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80'),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Elias Thorne',
                      style: AppTypography.authorName
                          .copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const Spacer(),
                    Icon(Icons.bookmark_border,
                        size: 20, color: AppTypography.bodyText.color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextOnly(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppTheme.cardOffWhite,
        borderRadius: BorderRadius.circular(12.0),
        border: isDark ? Border.all(color: Colors.grey.shade800) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.category.toUpperCase(),
              style: AppTypography.categoryLabelBright),
          const SizedBox(height: 8.0),
          Text(
            post.title,
            style: AppTypography.articleTitle
                .copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8.0),
          Text(
            post.body,
            style: AppTypography.bodyText,
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=100&q=80'),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Sarah Jenkins',
                style: AppTypography.authorName
                    .copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1493612276216-ee3925520721?auto=format&fit=crop&w=600&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.category.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  post.title,
                  style: AppTypography.articleTitleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppTheme.cardLightBlue,
        borderRadius: BorderRadius.circular(12.0),
        border: isDark
            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=600&q=80',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.category.toUpperCase(),
                  style: AppTypography.categoryLabel.copyWith(
                    color: isDark ? theme.colorScheme.primary : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  post.title,
                  style: AppTypography.articleTitle
                      .copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8.0),
                Text(
                  post.body,
                  style: AppTypography.bodyText,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.colorScheme.onSurface,
                                width: 1.0)),
                      ),
                      child: Text(
                        'Read the Archive',
                        style: AppTypography.actionLink
                            .copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const Text('OCT 12, 2023', style: AppTypography.metaData),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
