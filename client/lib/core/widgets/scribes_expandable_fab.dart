import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../features/compose/application/compose_provider.dart';
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
                  ref.read(composeProvider.notifier).reset();
                  context.push('/compose');
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: colors.glassBlur,
                  sigmaY: colors.glassBlur,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.glassFill,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.goldEdge, width: 1.5),
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
                              color: colors.primaryText,
                              size: 26,
                            )
                          : HugeIcon(
                              key: const ValueKey('open'),
                              icon: HugeIcons.strokeRoundedQuillWrite01,
                              color: colors.primaryText,
                              size: 26,
                            ),
                    ),
                  ),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: colors.glassBlur,
                    sigmaY: colors.glassBlur,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.glassFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border, width: 1.0),
                    ),
                    child: Text(
                      label,
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: colors.glassBlur,
                        sigmaY: colors.glassBlur,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.glassFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border, width: 1.0),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: icon,
                            color: colors.primaryText,
                            size: 20,
                          ),
                        ),
                      ),
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
