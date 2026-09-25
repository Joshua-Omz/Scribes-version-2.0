import 'package:flutter/material.dart';

/// Decouples scroll physics, pagination lookahead, and fling detection from the widget tree.
/// Eliminates the need for a wrapping [NotificationListener] on the Feed surface.
class FeedScrollCoordinator {
  final ScrollController controller;
  final VoidCallback onNearEnd;
  final ValueChanged<bool> onScrollStateChanged;

  bool _isFlinging = false;
  double _lastTriggerOffset = 0;
  ScrollPosition? _attachedPosition;
  VoidCallback? _isScrollingListener;

  FeedScrollCoordinator({
    ScrollController? controller,
    required this.onNearEnd,
    required this.onScrollStateChanged,
  }) : controller = controller ?? ScrollController() {
    this.controller.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!controller.hasClients) return;
    final position = controller.position;

    // Attach to position.isScrollingNotifier if position changed or not yet attached
    if (_attachedPosition != position) {
      _detachPositionListener();
      _attachedPosition = position;
      _isScrollingListener = () {
        final moving = position.isScrollingNotifier.value;
        if (_isFlinging != moving) {
          _isFlinging = moving;
          onScrollStateChanged(moving);
        }
      };
      position.isScrollingNotifier.addListener(_isScrollingListener!);
    }

    // 1. Engine-native fling detection check
    final isMoving = position.isScrollingNotifier.value;
    if (_isFlinging != isMoving) {
      _isFlinging = isMoving;
      onScrollStateChanged(isMoving);
    }

    // 2. Throttled pagination lookahead (only evaluate once every 150px displacement)
    final currentPixels = position.pixels;
    if ((currentPixels - _lastTriggerOffset).abs() > 150) {
      _lastTriggerOffset = currentPixels;
      if (currentPixels >= position.maxScrollExtent - 800) {
        onNearEnd();
      }
    }
  }

  void _detachPositionListener() {
    if (_attachedPosition != null && _isScrollingListener != null) {
      _attachedPosition!.isScrollingNotifier.removeListener(_isScrollingListener!);
      _isScrollingListener = null;
      _attachedPosition = null;
    }
  }

  void dispose() {
    controller.removeListener(_handleScroll);
    _detachPositionListener();
    controller.dispose();
  }
}

