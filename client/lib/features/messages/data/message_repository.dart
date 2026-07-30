import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/storage/database_provider.dart';
import 'package:scribes/core/storage/drift_database.dart' as db;
import 'package:scribes/features/messages/data/message_api.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:uuid/uuid.dart';

final messageRepositoryProvider = Provider((ref) {
  final api = ref.watch(messageApiProvider);
  final database = ref.watch(databaseProvider);
  return MessageRepository(api, database);
});

class MessageRepository {
  final MessageApi _api;
  final db.ScribesDatabase _db;

  MessageRepository(this._api, this._db);

  Future<MessageRequest> sendRequest(String toUserId, String firstMessage) async {
    return _api.sendRequest(toUserId, firstMessage);
  }

  Future<List<MessageRequest>> getPendingRequests() async {
    return _api.getPendingRequests();
  }

  Future<Conversation> approveRequest(String requestId) async {
    final conv = await _api.approveRequest(requestId);
    await _saveConversationToDb(conv);
    return conv;
  }

  Future<void> rejectRequest(String requestId) async {
    await _api.rejectRequest(requestId);
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final conversations = await _api.getConversations();
      await _db.batch((batch) {
        batch.insertAll(
          _db.conversations,
          conversations.map((c) => db.Conversation(
                id: c.id,
                userAId: c.userAId,
                userBId: c.userBId,
                blocked: c.blocked,
                createdAt: c.createdAt,
                lastActive: c.lastActive,
              )),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
      return conversations;
    } catch (e) {
      // Fallback to offline
      final offline = await _db.select(_db.conversations).get();
      return offline.map((c) => Conversation(
            id: c.id,
            userAId: c.userAId,
            userBId: c.userBId,
            blocked: c.blocked,
            createdAt: c.createdAt,
            lastActive: c.lastActive,
          )).toList();
    }
  }

  Stream<List<Message>> watchMessages(String conversationId) {
    return (_db.select(_db.messages)..where((m) => m.conversationId.equals(conversationId))..orderBy([(m) => drift.OrderingTerm.desc(m.sentAt)])).watch().map((list) {
      return list.map((m) => Message(
            id: m.id,
            conversationId: m.conversationId,
            senderId: m.senderId,
            body: m.body,
            isDeleted: m.isDeleted,
            sentAt: m.sentAt,
            replyToId: m.replyToId,
            editedAt: m.editedAt,
            status: m.status,
          )).toList();
    });
  }

  Future<void> refreshMessages(String conversationId, {DateTime? cursorTs}) async {
    try {
      final messages = await _api.getMessages(conversationId, cursorTs: cursorTs);
      await _db.batch((batch) {
        batch.insertAll(
          _db.messages,
          messages.map((m) => db.Message(
                id: m.id,
                conversationId: m.conversationId,
                senderId: m.senderId,
                body: m.body,
                isDeleted: m.isDeleted,
                sentAt: m.sentAt,
                replyToId: m.replyToId,
                editedAt: m.editedAt,
                status: 'sent', // from API is always sent
              )),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      // Ignore network errors on refresh
    }
  }

  Future<void> sendMessage(String conversationId, String body, String senderId, {String? replyToId}) async {
    // 1. Optimistic UI: Insert pending message
    final pendingId = const Uuid().v4();
    final tempMsg = db.Message(
      id: pendingId,
      conversationId: conversationId,
      senderId: senderId,
      body: body,
      isDeleted: false,
      sentAt: DateTime.now(),
      replyToId: replyToId,
      editedAt: null,
      status: 'pending',
    );
    await _db.into(_db.messages).insert(tempMsg);

    // 2. Perform API call asynchronously
    try {
      final msg = await _api.sendMessage(conversationId, body, replyToId: replyToId);
      
      // 3. On success, delete pending and insert real message
      await _db.transaction(() async {
        await (_db.delete(_db.messages)..where((t) => t.id.equals(pendingId))).go();
        await _db.into(_db.messages).insert(
          db.Message(
            id: msg.id,
            conversationId: msg.conversationId,
            senderId: msg.senderId,
            body: msg.body,
            isDeleted: msg.isDeleted,
            sentAt: msg.sentAt,
            replyToId: msg.replyToId,
            editedAt: msg.editedAt,
            status: 'sent',
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      // 4. On error, mark pending as error
      await (_db.update(_db.messages)..where((t) => t.id.equals(pendingId))).write(
        const db.MessagesCompanion(status: drift.Value('error')),
      );
    }
  }
  
  Stream<Message> streamRealtimeMessages(String conversationId) async* {
    await for (final msg in _api.streamMessages(conversationId)) {
      await _db.into(_db.messages).insert(
        db.Message(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          body: msg.body,
          isDeleted: msg.isDeleted,
          sentAt: msg.sentAt,
          replyToId: msg.replyToId,
          editedAt: msg.editedAt,
          status: 'sent',
        ),
        mode: drift.InsertMode.insertOrReplace,
      );
      yield msg;
    }
  }

  Future<void> _saveConversationToDb(Conversation c) async {
    await _db.into(_db.conversations).insert(
      db.Conversation(
        id: c.id,
        userAId: c.userAId,
        userBId: c.userBId,
        blocked: c.blocked,
        createdAt: c.createdAt,
        lastActive: c.lastActive,
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
  }
}
