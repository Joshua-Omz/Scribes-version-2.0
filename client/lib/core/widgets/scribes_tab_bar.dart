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
    this.tabs = const ['Following', 'Seek'],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      width: double.infinity,
      color: colors.background,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tabs.asMap().entries.map((entry) {
              return _buildTab(context, colors, entry.value, entry.key);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, dynamic colors, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: ScribesTextStyles.labelLg.copyWith(
            color: isSelected ? colors.surfaceRaised : colors.secondaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
