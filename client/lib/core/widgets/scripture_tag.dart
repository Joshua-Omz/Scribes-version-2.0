import 'package:flutter/material.dart';

class ScriptureTag extends StatelessWidget {
  final String reference;
  final VoidCallback onTap;

  const ScriptureTag({
    super.key,
    required this.reference,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, color: theme.colorScheme.primary, size: 14),
            const SizedBox(width: 6),
            Text(
              reference,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
