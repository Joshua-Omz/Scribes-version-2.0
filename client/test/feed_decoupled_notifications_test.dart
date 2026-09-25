import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/core/state/scroll_aware_state_mixin.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/widgets/scribes_notification_badge_button.dart';
import 'package:scribes/features/feed/presentation/feed_scroll_coordinator.dart';
import 'package:scribes/features/notifications/application/notification_provider.dart';

// Test harness class that uses ScrollAwareStateMixin
class _TestScrollAwareNotifier with ScrollAwareStateMixin<String> {
  @override
  AsyncValue<String> state = const AsyncData('initial');
}

void main() {
  group('Feed Scroll Coordinator & Decoupled Notifications Tests', () {
    setUp(() {
      ScrollAwareStateMixin.isScrolling.value = false;
    });

    test('ScrollAwareStateMixin updates immediately when not scrolling', () {
      final notifier = _TestScrollAwareNotifier();
      expect(notifier.state.value, 'initial');

      notifier.setStateWhenIdle(const AsyncData('updated_immediate'));
      expect(notifier.state.value, 'updated_immediate');
    });

    testWidgets('ScrollAwareStateMixin defers update while scrolling and flushes on scroll end', (tester) async {
      final notifier = _TestScrollAwareNotifier();
      ScrollAwareStateMixin.isScrolling.value = true;

      // Update while scrolling — should be deferred
      notifier.setStateWhenIdle(const AsyncData('deferred_update'));
      expect(notifier.state.value, 'initial');

      // Scroll ends
      ScrollAwareStateMixin.isScrolling.value = false;
      await tester.pump(); // Pump frame for post-frame callback

      expect(notifier.state.value, 'deferred_update');
    });

    testWidgets('ScrollAwareStateMixin sequence token prevents older callbacks from overwriting newer state', (tester) async {
      final notifier = _TestScrollAwareNotifier();
      ScrollAwareStateMixin.isScrolling.value = true;

      notifier.setStateWhenIdle(const AsyncData('deferred_1'));
      expect(notifier.state.value, 'initial');

      // End scroll, queue flush
      ScrollAwareStateMixin.isScrolling.value = false;

      // Before frame pump, an immediate update arrives
      notifier.setStateWhenIdle(const AsyncData('newer_immediate'));

      await tester.pump(); // Flush frame callback

      // Must remain newer_immediate, not overwritten by deferred_1
      expect(notifier.state.value, 'newer_immediate');
    });

    testWidgets('FeedScrollCoordinator throttles pagination checks and detects end', (tester) async {
      int nearEndCalls = 0;
      bool isScrollingReported = false;

      final coordinator = FeedScrollCoordinator(
        onNearEnd: () => nearEndCalls++,
        onScrollStateChanged: (scrolling) => isScrollingReported = scrolling,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: coordinator.controller,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(height: 100, child: Text('Item $index')),
                    childCount: 40, // 4000px total extent
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(nearEndCalls, 0);

      // Scroll down by 50px (< 150px displacement threshold)
      coordinator.controller.jumpTo(50);
      await tester.pump();
      expect(nearEndCalls, 0);

      // Jump to near end (3600px of 4000px, maxScrollExtent - 400px <= maxScrollExtent - 800px)
      coordinator.controller.jumpTo(3600);
      await tester.pump();
      expect(nearEndCalls, 1);

      coordinator.dispose();
    });

    testWidgets('ScribesNotificationBadgeButton displays badge dot when unread exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeProvider.overrideWithValue(ScribesColors.night),
            hasUnreadNotificationsProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ScribesNotificationBadgeButton(),
            ),
          ),
        ),
      );

      await tester.pump();

      // The notification bell icon button should be present
      expect(find.byType(ScribesNotificationBadgeButton), findsOneWidget);
      // Tooltip 'Notifications'
      expect(find.byTooltip('Notifications'), findsOneWidget);

      // Verify the badge dot container is rendered
      final containerFinders = find.descendant(
        of: find.byType(ScribesNotificationBadgeButton),
        matching: find.byType(Container),
      );

      // Find container with width == 7.5
      bool foundBadgeDot = false;
      for (final element in containerFinders.evaluate()) {
        final container = element.widget as Container;
        final constraints = container.constraints;
        if (constraints?.maxWidth == 7.5 && constraints?.maxHeight == 7.5) {
          foundBadgeDot = true;
          break;
        }
      }
      expect(foundBadgeDot, isTrue, reason: 'Badge dot container of 7.5x7.5 must be visible');
    });

    testWidgets('ScribesNotificationBadgeButton hides badge dot when no unread', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeProvider.overrideWithValue(ScribesColors.night),
            hasUnreadNotificationsProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ScribesNotificationBadgeButton(),
            ),
          ),
        ),
      );

      await tester.pump();

      final containerFinders = find.descendant(
        of: find.byType(ScribesNotificationBadgeButton),
        matching: find.byType(Container),
      );

      bool foundBadgeDot = false;
      for (final element in containerFinders.evaluate()) {
        final container = element.widget as Container;
        final constraints = container.constraints;
        if (constraints?.maxWidth == 7.5 && constraints?.maxHeight == 7.5) {
          foundBadgeDot = true;
          break;
        }
      }
      expect(foundBadgeDot, isFalse, reason: 'Badge dot container must NOT be visible when hasUnread is false');
    });

    testWidgets('CupertinoSliverRefreshControl participates natively in CustomScrollView', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                CupertinoSliverRefreshControl(
                  key: const ValueKey('refresh_control'),
                  onRefresh: () async {
                    refreshed = true;
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SizedBox(height: 50, child: Text('Post $index')),
                    childCount: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('refresh_control')), findsOneWidget);
      expect(refreshed, isFalse);

      // Drag down past the refreshTriggerPullDistance (default 100px)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshed, isTrue);
    });
  });
}

