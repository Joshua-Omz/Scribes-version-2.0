import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scribes_image_resolver.dart';

class ScribesAvatar extends ConsumerWidget {
  final String? imageUrl;
  final String authorName;
  final double radius;

  const ScribesAvatar({
    super.key,
    this.imageUrl,
    required this.authorName,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
        color: colors.surfaceRaised,
      ),
      child: ClipOval(
        child: hasUrl
            ? ScribesImageResolver.buildImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: (radius * 4).toInt(),
                placeholder: (context, url) => _buildFallback(colors),
                errorWidget: (context, url, error) => _buildFallback(colors),
                fallback: _buildFallback(colors),
              )
            : _buildFallback(colors),
      ),
    );
  }

  Widget _buildFallback(ScribesColors colors) {
    return Center(
      child: Text(
        authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
        style: TextStyle(
          color: colors.primaryText,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
