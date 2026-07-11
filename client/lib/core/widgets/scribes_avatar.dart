import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScribesAvatar extends ConsumerWidget {
  final String? imageUrl;
  final String authorName;
  final double radius;

  const ScribesAvatar({
    super.key,
    this.imageUrl,
    required this.authorName,
    this.radius = 20,
  }) ;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
        color: colors.surfaceRaised,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(colors),
              )
            : _buildFallback(colors),
      ),
    );
  }

  Widget _buildFallback(colors) {
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
