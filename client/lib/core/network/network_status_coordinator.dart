import 'package:flutter/material.dart';

import '../theme/scribes_colors.dart';
import '../widgets/scribes_toast.dart';

class NetworkStatusCoordinator {
  static final NetworkStatusCoordinator instance = NetworkStatusCoordinator._();
  NetworkStatusCoordinator._();

  bool _isOffline = false;
  DateTime? _lastOfflineToastTime;

  bool get isOffline => _isOffline;

  /// Called when an HTTP request encounters a transport/socket/timeout failure
  void handleNetworkFailure(ScribesColors colors) {
    final now = DateTime.now();

    // Throttle offline toasts: show at most once every 6 seconds to prevent toast storms
    if (_lastOfflineToastTime == null ||
        now.difference(_lastOfflineToastTime!) > const Duration(seconds: 6)) {
      _lastOfflineToastTime = now;
      _isOffline = true;

      ScribesToast.show(
        null, // Uses root scaffoldMessengerKey
        'You are offline. Showing cached content.',
        colors,
        icon: Icons.wifi_off_rounded,
        isError: true,
      );
    }
  }

  /// Called when an HTTP request successfully completes a server handshake
  void handleNetworkSuccess(ScribesColors colors) {
    if (_isOffline) {
      _isOffline = false;
      _lastOfflineToastTime = null;

      ScribesToast.show(
        null, // Uses root scaffoldMessengerKey
        'Back online. Content updated.',
        colors,
        icon: Icons.cloud_done_rounded,
        isError: false,
      );
    }
  }
}
