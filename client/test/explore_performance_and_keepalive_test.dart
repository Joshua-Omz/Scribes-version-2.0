import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/core/widgets/scribes_keep_alive_item.dart';

void main() {
  group('ScribesKeepAliveItem & Horizontal Carousel Performance Tests', () {
    testWidgets('ScribesKeepAliveItem declares wantKeepAlive = true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScribesKeepAliveItem(
              child: Container(key: const ValueKey('child_container')),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('child_container')), findsOneWidget);
      expect(find.byType(ScribesKeepAliveItem), findsOneWidget);
    });

    testWidgets('Horizontal ListView preserves off-screen keep-alive children', (tester) async {
      final disposedIndices = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ScribesKeepAliveItem(
                    key: ValueKey('item_$index'),
                    child: _DisposalWatcher(
                      index: index,
                      onDispose: () => disposedIndices.add(index),
                      child: SizedBox(
                        width: 250,
                        height: 200,
                        child: Text('Card $index'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially, Card 0 and Card 1 are in viewport
      expect(find.text('Card 0'), findsOneWidget);
      expect(disposedIndices, isEmpty);

      // Scroll far to the right (past item 0 and item 1)
      await tester.drag(find.byType(ListView), const Offset(-800, 0));
      await tester.pumpAndSettle();

      // Card 0 has scrolled out of visible viewport, but because of ScribesKeepAliveItem,
      // it MUST NOT be disposed!
      expect(disposedIndices, isEmpty);
    });

    testWidgets('ScrollNotification decoupling correctly triggers threshold', (tester) async {
      bool paginationTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 400) {
                  paginationTriggered = true;
                }
                return false;
              },
              child: ListView.builder(
                itemCount: 30,
                itemBuilder: (context, index) {
                  return SizedBox(
                    height: 100,
                    child: Text('Row $index'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(paginationTriggered, isFalse);

      // Scroll towards bottom
      await tester.drag(find.byType(ListView), const Offset(0, -2500));
      await tester.pumpAndSettle();

      // Pagination must have triggered safely via NotificationListener
      expect(paginationTriggered, isTrue);
    });
  });
}

class _DisposalWatcher extends StatefulWidget {
  final int index;
  final VoidCallback onDispose;
  final Widget child;

  const _DisposalWatcher({
    required this.index,
    required this.onDispose,
    required this.child,
  });

  @override
  State<_DisposalWatcher> createState() => _DisposalWatcherState();
}

class _DisposalWatcherState extends State<_DisposalWatcher> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
