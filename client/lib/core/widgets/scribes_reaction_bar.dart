import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';

class ScribesReactionBar extends ConsumerWidget {
  final int amenCount;
  final int insightCount;
  final int thoughtProvokingCount;
  final int commentCount;
  final Function(String) onReact;
  final VoidCallback onComment;
  final List<String> userReactions;

  const ScribesReactionBar({
    super.key,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    required this.onReact,
    required this.onComment,
    this.userReactions = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ReactionChip(
            icon: Icons.local_fire_department_outlined,
            label: 'Amen',
            count: amenCount.toString(),
            onTap: () => onReact('amen'),
            color: colors.orange,
            isSelected: userReactions.contains('amen'),
            colors: colors,
          ),
          const SizedBox(width: 12),
          _ReactionChip(
            icon: Icons.lightbulb_outline,
            label: 'Insight',
            count: insightCount.toString(),
            onTap: () => onReact('insightful'),
            color: colors.gold,
            isSelected: userReactions.contains('insightful'),
            colors: colors,
          ),
          const SizedBox(width: 12),
          _ReactionChip(
            icon: Icons.diamond_outlined,
            label: 'Deep',
            count: thoughtProvokingCount.toString(),
            onTap: () => onReact('thought_provoking'),
            color: colors.primaryText,
            isSelected: userReactions.contains('thought_provoking'),
            colors: colors,
          ),
          const SizedBox(width: 12),
          _ReactionChip(
            icon: Icons.chat_bubble_outline,
            label: 'Discuss',
            count: commentCount.toString(),
            onTap: onComment,
            color: colors.primaryText,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final VoidCallback onTap;
  final Color color;
  final bool isSelected;
  final dynamic colors;

  const _ReactionChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    required this.color,
    this.isSelected = false,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = isSelected ? color : colors.secondaryText;

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
              '$label $count',
              style: ScribesTextStyles.labelLg.copyWith(color: displayColor),
            ),
          ],
        ),
      ),
    );
  }
}
