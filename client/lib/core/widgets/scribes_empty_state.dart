import 'package:flutter/material.dart';

class ScribesEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? ctaText;
  final VoidCallback? onCtaTap;

  const ScribesEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.ctaText,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.book_outlined,
                size: 64,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaText != null && onCtaTap != null) ...[
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: onCtaTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(ctaText!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
