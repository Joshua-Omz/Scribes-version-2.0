import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // Compose is an action, not a tab
      context.push('/compose');
      return;
    }

    // Map UI indices to branch indices
    int branchIndex = 0;
    if (index == 0) branchIndex = 0;
    else if (index == 1) branchIndex = 1;
    else if (index == 3) branchIndex = 2;
    else if (index == 4) branchIndex = 3;

    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      branchIndex,
      // A common pattern when tapping an active tab is to pop to the initial location.
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Map branch index back to UI index
    int uiIndex = 0;
    if (navigationShell.currentIndex == 0) uiIndex = 0;
    else if (navigationShell.currentIndex == 1) uiIndex = 1;
    else if (navigationShell.currentIndex == 2) uiIndex = 3;
    else if (navigationShell.currentIndex == 3) uiIndex = 4;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ScribesBottomNav(
        currentIndex: uiIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class ScribesBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ScribesBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
              _buildNavItem(context, colors, Icons.breakfast_dining, 'scroll', 0),
              _buildNavItem(context, colors, Icons.search, 'Search', 1),
              _buildNavItem(context, colors, Icons.drafts_outlined, 'Drafts', 3),
              _buildNavItem(context, colors, Icons.note_add_outlined, 'Notes', 4),
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
        onTap: () => onTap(index),
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
