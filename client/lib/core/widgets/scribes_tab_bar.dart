import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScribesTabBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;

  const ScribesTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs = const ['Following', 'Seek'], // Default for backward compatibility
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabs.asMap().entries.map((entry) {
          final isLast = entry.key == tabs.length - 1;
          return Row(
            children: [
              _buildTab(context, colors, entry.value, entry.key),
              if (!isLast) const SizedBox(width: 32),
            ],
          );
        }).toList(),
      ),
    );
  }
  Widget _buildTab(BuildContext context, colors, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: colors.gold, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: ScribesTextStyles.labelLg.copyWith(
            color: isSelected ? colors.gold : colors.secondaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
