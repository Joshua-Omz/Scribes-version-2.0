import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/core/network/network_status_coordinator.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NetworkStatusCoordinator transitions and throttles safely',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const Scaffold(
          body: Text('Test'),
        ),
      ),
    );

    final coordinator = NetworkStatusCoordinator.instance;
    const colors = ScribesColors.night;

    // Initially online
    expect(coordinator.isOffline, isFalse);

    // Trigger failure
    coordinator.handleNetworkFailure(colors);
    await tester.pump();
    expect(coordinator.isOffline, isTrue);

    // Throttled rapid failure does not throw or desync state
    coordinator.handleNetworkFailure(colors);
    await tester.pump();
    expect(coordinator.isOffline, isTrue);

    // Trigger recovery
    coordinator.handleNetworkSuccess(colors);
    await tester.pump();
    expect(coordinator.isOffline, isFalse);
  });
}
