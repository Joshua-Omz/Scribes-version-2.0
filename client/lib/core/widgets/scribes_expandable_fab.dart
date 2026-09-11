import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../features/compose/presentation/compose_type_sheet.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';

class ScribesExpandableFab extends ConsumerStatefulWidget {
  const ScribesExpandableFab({super.key});

  @override
  ConsumerState<ScribesExpandableFab> createState() =>
      _ScribesExpandableFabState();
}

class _ScribesExpandableFabState extends ConsumerState<ScribesExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: !_isOpen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Study Group
              _buildAction(
                colors,
                label: 'Study Group',
                icon: HugeIcons.strokeRoundedUserGroup,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Study Groups coming soon!',
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.surface,
                        ),
                      ),
                      backgroundColor: colors.primaryText,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                index: 3,
              ),
              _buildAction(
                colors,
                label: 'Drafts',
                icon: HugeIcons.strokeRoundedFolder01,
                onTap: () => context.push('/drafts'),
                index: 2,
              ),
              _buildAction(
                colors,
                label: 'Create Note',
                icon: HugeIcons.strokeRoundedFileEdit,
                onTap: () => context.push('/notes/edit'),
                index: 1,
              ),
              _buildAction(
                colors,
                label: 'Create Post',
                icon: HugeIcons.strokeRoundedPencilEdit02,
                onTap: () {
                  ComposeTypeSheet.show(context);
                },
                index: 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ScribesBounceButton(
          onTap: _toggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceRaised.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.gold.withValues(alpha: 0.75),
                width: 1.5,
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: child.key == const ValueKey('close')
                      ? Tween<double>(
                          begin: -0.25,
                          end: 0.0,
                        ).animate(anim)
                      : Tween<double>(
                          begin: 0.25,
                          end: 0.0,
                        ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _isOpen
                    ? HugeIcon(
                        key: const ValueKey('close'),
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: colors.gold,
                        size: 24,
                      )
                    : HugeIcon(
                        key: const ValueKey('open'),
                        icon: HugeIcons.strokeRoundedQuillWrite01,
                        color: colors.gold,
                        size: 24,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(
    dynamic colors, {
    required String label,
    required dynamic icon,
    required VoidCallback onTap,
    required int index,
  }) {
    final double start = 0.0 + (index * 0.1);
    final double end = 0.6 + (index * 0.1);
    final Animation<double> anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return ScaleTransition(
      scale: anim,
      child: FadeTransition(
        opacity: anim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  label,
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ScribesBounceButton(
                onTap: () {
                  _toggle();
                  onTap();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.gold.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      color: colors.gold,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6), // Align with main FAB center
            ],
          ),
        ),
      ),
    );
  }
}

