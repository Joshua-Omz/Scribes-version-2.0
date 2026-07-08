import 'package:flutter/material.dart';
import 'package:scribes/core/theme/scribes_colors.dart';

class ScribesReactionBar extends StatelessWidget {
  final int amenCount;
  final int insightCount;
  final int thoughtCount;
  final Function(String) onReact;
  final VoidCallback onComment;

  const ScribesReactionBar({
    super.key,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtCount = 0,
    required this.onReact,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ScribesColors>()!;

    return Row(
      children: [
        _ReactionChip(
          icon: Icons.local_fire_department_outlined,
          count: amenCount.toString(),
          onTap: () => onReact('amen'),
          color: colors.orange,
        ),
        const SizedBox(width: 12),
        _ReactionChip(
          icon: Icons.lightbulb_outline,
          count: insightCount.toString(),
          onTap: () => onReact('insight'),
          color: colors.gold,
        ),
        const SizedBox(width: 12),
        _ReactionChip(
          icon: Icons.chat_bubble_outline,
          count: thoughtCount.toString(),
          onTap: onComment,
          color: colors.primaryText,
        ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;
  final Color color;
  final bool isSelected;

  const _ReactionChip({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = isSelected ? color : color.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: displayColor.withValues(alpha: isSelected ? 1.0 : 0.2),
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? displayColor.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: displayColor),
            const SizedBox(width: 6),
            Text(
              count,
              style: theme.textTheme.labelMedium?.copyWith(color: displayColor),
            ),
          ],
        ),
      ),
    );
  }
}
