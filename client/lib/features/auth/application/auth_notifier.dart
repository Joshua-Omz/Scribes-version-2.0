import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';
import '../../sync/application/sync_service.dart';
import '../../messages/data/message_repository.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/network_sync_notifier.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final hasToken = await repo.hasToken();
    if (!hasToken) {
      return null;
    }

    // Fetch the user profile from the /me endpoint
    try {
      final user = await repo.getMe();
      // Claim any offline guest records
      await _claimGuestRecords(user.id);
      // Trigger sync in background
      _triggerSync(user.id);
      return user;
    } catch (e) {
      // If fetching the profile fails (e.g., token expired/invalid on server),
      // we might want to log out or just return null.
      // For now, if /me fails, we assume we're not authenticated.
      await repo.logout();
      return null;
    }
  }

  Future<void> _claimGuestRecords(String newUserId) async {
    try {
      final storage = ref.read(secureStorageProvider);
      final guestId = await storage.getGuestId();
      if (guestId != null && guestId.isNotEmpty && guestId != newUserId) {
        final db = ref.read(databaseProvider);
        await db.transaction(() async {
          // Re-parent unsynced guest notes to the newly authenticated user
          await (db.update(
            db.notes,
          )..where((t) => t.authorId.equals(guestId))).write(
            NotesCompanion(
              authorId: Value(newUserId),
              isSynced: const Value(false),
            ),
          );

          // Re-parent unsynced guest drafts to the newly authenticated user
          await (db.update(
            db.drafts,
          )..where((t) => t.authorId.equals(guestId))).write(
            DraftsCompanion(
              authorId: Value(newUserId),
              isSynced: const Value(false),
            ),
          );

          // Re-parent notebooks
          await (db.update(db.notebooks)
                ..where((t) => t.ownerId.equals(guestId)))
              .write(NotebooksCompanion(ownerId: Value(newUserId)));
        });
      }
    } catch (e) {
      debugPrint('Failed to claim guest records: $e');
    }
  }

  void _triggerSync(String? userId) {
    // Fire and forget
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sync(authorId: userId);

        if (userId != null) {
          // Initialize network connectivity listener
          ref.read(networkSyncProvider);

          final messageRepo = ref.read(messageRepositoryProvider);
          await messageRepo.flushOfflineQueue(userId);
          await messageRepo.syncMissedMessages();
        }
      } catch (e) {
        debugPrint('Background sync failed: $e');
      }
    });
  }

  Future<void> register({
    required String email,
    required String handle,
    required String displayName,
    required String password,
    required bool isChurch,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        email: email,
        handle: handle,
        displayName: displayName,
        password: password,
        isChurch: isChurch,
      );
      await _claimGuestRecords(user.id);
      _triggerSync(user.id);
      return user;
    });
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      await _claimGuestRecords(user.id);
      _triggerSync(user.id);
      return user;
    });
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.loginWithGoogle(idToken);
      await _claimGuestRecords(user.id);
      _triggerSync(user.id);
      return user;
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    final db = ref.read(databaseProvider);
    await repo.logout();
    await db.clearAllData(preserveUnsynced: true);
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    required String handle,
    required String displayName,
    String? bio,
    bool isChurch = false,
    String? avatarUrl,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final updatedUser = await repo.updateProfile(
      handle: handle,
      displayName: displayName,
      bio: bio,
      isChurch: isChurch,
      avatarUrl: avatarUrl,
    );
    state = AsyncData(updatedUser);
  }

  Future<void> updateTags(List<String> tags) async {
    final repo = ref.read(authRepositoryProvider);
    try {
      final updatedUser = await repo.updateTags(tags);
      state = AsyncData(updatedUser);
    } catch (e) {
      // If the API call fails, still update local state so the router gate
      // doesn't trap the user on onboarding. The onboarding flow already
      // sends tags via OnboardingApi.saveUserTopics() as a separate call,
      // so this is a best-effort sync of auth state.
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(selectedTags: tags);
        state = AsyncData(updatedUser);
      }
      debugPrint('updateTags API call failed, updated local state only: $e');
    }
  }

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.updateEmail(
      newEmail: newEmail,
      currentPassword: currentPassword,
    );
    // Reload user to get updated email
    final user = await repo.getMe();
    state = AsyncData(user);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
