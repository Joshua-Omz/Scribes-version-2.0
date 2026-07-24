import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScribesBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptic;
  final double scaleFactor;

  const ScribesBounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enableHaptic = true,
    this.scaleFactor = 0.92,
  });

  @override
  State<ScribesBounceButton> createState() => _ScribesBounceButtonState();
}

class _ScribesBounceButtonState extends State<ScribesBounceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(ScribesBounceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleFactor != widget.scaleFactor) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    if (!widget.enableHaptic) return;
    HapticFeedback.lightImpact();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    _triggerHaptic();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
