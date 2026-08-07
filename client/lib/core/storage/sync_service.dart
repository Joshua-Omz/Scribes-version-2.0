import 'package:dio/dio.dart';
import 'package:scribes/core/network/endpoints.dart';
import '../../features/sync/domain/pending_record.dart';
import '../../features/sync/domain/sync_response.dart';
import 'drift_database.dart';

class SyncService {
  final Dio _api;
  final ScribesDatabase _storage;

  SyncService(this._api, this._storage);

  Future<int> getLastServerSequence() async {
    final noteMax = await _storage.notesDao.getMaxServerSequence();
    final draftMax = await _storage.draftsDao.getMaxServerSequence();
    final postMax = await _storage.postsDao.getMaxServerSequence();

    final values = [noteMax, draftMax, postMax].whereType<int>();
    if (values.isEmpty) return 0;
    return values.reduce((max, v) => v > max ? v : max);
  }

  Future<List<PendingRecord>> getLocalOnlyRecords() async {
    final pendingNotes = await _storage.notesDao.getLocalOnly();
    final pendingDrafts = await _storage.draftsDao.getLocalOnly();

    return [
      ...pendingNotes.map((n) => PendingRecord.fromNote(n)),
      ...pendingDrafts.map((d) => PendingRecord.fromDraft(d)),
    ];
  }

  Future<void> applyDelta(SyncDeltaResponse delta) async {
    for (final record in delta.records) {
      try {
        switch (record.type) {
          case 'note':
            await _storage.notesDao.upsertFromServer(record);
            break;
          case 'draft':
            await _storage.draftsDao.upsertFromServer(record);
            break;
          case 'post':
            await _storage.postsDao.upsertFromServer(record);
            break;
          default:
            print('Unrecognized sync record type: ${record.type}');
        }
      } catch (e, stack) {
        print('Failed to apply sync record ${record.localId}: $e');
      }
    }
  }

  Future<void> confirmSynced(SyncPushResponse response) async {
    for (final confirmation in response.confirmed) {
      switch (confirmation.type) {
        case 'note':
          await _storage.notesDao.markSynced(
            confirmation.localId,
            confirmation.serverSequence,
          );
          break;
        case 'draft':
          await _storage.draftsDao.markSynced(
            confirmation.localId,
            confirmation.serverSequence,
          );
          break;
      }
    }
  }

  Future<void> syncNow() async {
    // 1. Pull
    final lastSeq = await getLastServerSequence();
    
    final deltaResponse = await _api.get(
      Endpoints.syncPull, 
      queryParameters: {'seq': lastSeq.toString()}
    );
    final delta = SyncDeltaResponse.fromJson(deltaResponse.data);
    await applyDelta(delta);

    // 2. Push
    final pending = await getLocalOnlyRecords();
    
    if (pending.isNotEmpty) {
      final pushResponse = await _api.post(
        Endpoints.syncPush, 
        data: {'events': pending.map((r) => r.toJson()).toList()}
      );
      final result = SyncPushResponse.fromJson(pushResponse.data);
      await confirmSynced(result);
    }
  }
}
