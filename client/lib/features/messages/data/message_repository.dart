import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/storage/database_provider.dart';
import 'package:scribes/core/storage/drift_database.dart' as db;
import 'package:scribes/features/messages/data/message_api.dart';
import 'package:scribes/features/messages/domain/message.dart';

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
              )),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      // Ignore network errors on refresh
    }
  }

  Future<Message> sendMessage(String conversationId, String body, {String? replyToId}) async {
    final msg = await _api.sendMessage(conversationId, body, replyToId: replyToId);
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
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
    return msg;
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
