import 'package:flutter/material.dart';

class ScribesReactionBar extends StatelessWidget {
  final int amenCount;
  final int insightCount;
  final int thoughtCount;

  const ScribesReactionBar({
    super.key,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReactionChip(
          icon: Icons.local_fire_department_outlined,
          count: amenCount.toString(),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ReactionChip(
          icon: Icons.lightbulb_outline,
          count: insightCount.toString(),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        _ReactionChip(
          icon: Icons.edit_note_outlined,
          count: thoughtCount.toString(),
          onTap: () {},
        ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;
  final bool isSelected;

  const _ReactionChip({
    required this.icon,
    required this.count,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 1.0 : 0.2),
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              count,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
