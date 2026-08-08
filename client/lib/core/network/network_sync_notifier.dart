import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';

final networkSyncProvider = Provider<NetworkSyncNotifier>((ref) {
  return NetworkSyncNotifier(ref);
});

class NetworkSyncNotifier {
  final Ref _ref;
  bool _wasOffline = false;

  NetworkSyncNotifier(this._ref) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        _wasOffline = true;
      } else if (_wasOffline) {
        // We regained connection! Trigger syncing
        _wasOffline = false;
        _handleReconnection();
      }
    });
  }

  Future<void> _handleReconnection() async {
    final user = _ref.read(authProvider).value;
    if (user != null) {
      final messageRepo = _ref.read(messageRepositoryProvider);
      
      // 1. Flush outbound offline queue
      await messageRepo.flushOfflineQueue(user.id);
      
      // 2. Perform gap-filling sync for inbound missed messages
      await messageRepo.syncMissedMessages();
    }
  }
}
