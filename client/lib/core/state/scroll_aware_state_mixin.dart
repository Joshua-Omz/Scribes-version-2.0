import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mixin for Riverpod notifiers that manage data displayed in scrollable lists.
/// Ensures state updates do not trigger UI rebuilds during active scroll flings.
mixin ScrollAwareStateMixin<T> {
  /// Global flag to track if a scroll fling is actively moving the viewport.
  /// Should be updated by a scroll coordinator or scroll listener on the scrollable surface.
  static final ValueNotifier<bool> isScrolling = ValueNotifier<bool>(false);

  /// Abstract state accessors to allow mixin on any Riverpod AsyncNotifier variation
  AsyncValue<T> get state;
  set state(AsyncValue<T> value);

  AsyncValue<T>? _pendingState;
  Timer? _fallbackTimer;
  VoidCallback? _scrollListener;
  int _stateSequence = 0;

  /// Updates the provider's state safely. If a scroll is currently active,
  /// the update is deferred until scrolling stops or a fallback timeout occurs.
  void setStateWhenIdle(AsyncValue<T> newState) {
    ++_stateSequence;

    if (!isScrolling.value) {
      _cleanupPending();
      state = newState;
      return;
    }

    // Scroll is active — store the latest pending state
    _pendingState = newState;

    if (_scrollListener == null) {
      _scrollListener = () {
        if (!isScrolling.value && _pendingState != null) {
          _flushPendingState();
        }
      };
      isScrolling.addListener(_scrollListener!);

      // Maximum 500ms fallback timeout so continuous drags or unreleased touches
      // do not starve state updates indefinitely.
      _fallbackTimer?.cancel();
      _fallbackTimer = Timer(const Duration(milliseconds: 500), () {
        if (_pendingState != null) {
          _flushPendingState();
        }
      });
    }
  }

  void _flushPendingState() {
    _cleanupPending();
    if (_pendingState != null) {
      final next = _pendingState!;
      final token = _stateSequence;
      _pendingState = null;

      void applyState() {
        if (_stateSequence == token) {
          try {
            state = next;
          } catch (_) {
            // Guard against disposed notifier
          }
        }
      }

      // If the scheduler is already idle, apply immediately without frame delay
      if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        applyState();
        return;
      }

      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          applyState();
        });
        WidgetsBinding.instance.ensureVisualUpdate();
      } catch (_) {
        // Fallback for headless environments without initialized WidgetsBinding
        applyState();
      }
    }
  }

  void _cleanupPending() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    if (_scrollListener != null) {
      isScrolling.removeListener(_scrollListener!);
      _scrollListener = null;
    }
  }
}

