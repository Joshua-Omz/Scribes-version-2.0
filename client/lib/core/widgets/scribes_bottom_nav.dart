import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';


class ScribesBottomNav extends ConsumerWidget {
  final int currentIndex;

  const ScribesBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.push('/compose');
        break;
      case 3:
        context.go('/insights'); // Placeholder
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(context, colors, Icons.auto_stories, 'Bread', 0),
              _buildNavItem(context, colors, Icons.search, 'search', 1),
              _buildNavItem(context, colors, Icons.lightbulb_outline, 'Insights', 3),
              _buildNavItem(context, colors, Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
  
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, colors, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? colors.gold : colors.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: isSelected
                    ? Border(top: BorderSide(color: colors.gold, width: 2))
                    : null,
              ),
              padding: const EdgeInsets.only(top: 4),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: ScribesTextStyles.labelSm.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
