import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/storage/database_provider.dart';
import 'package:scribes/core/storage/drift_database.dart' as db;
import 'package:scribes/features/messages/data/message_api.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:scribes/features/messages/domain/contact.dart';
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

  Future<Conversation> getOrCreateDirectConversation(String toUserId) async {
    final conv = await _api.getOrCreateDirectConversation(toUserId);
    await _saveConversationToDb(conv);
    return conv;
  }

  Future<List<Contact>> searchContacts(String query) async {
    return _api.searchContacts(query);
  }

  Future<Conversation> approveRequest(String requestId) async {
    final conv = await _api.approveRequest(requestId);
    await _saveConversationToDb(conv);
    return conv;
  }

  Future<void> rejectRequest(String requestId) async {
    await _api.rejectRequest(requestId);
  }

  Stream<List<Conversation>> watchConversations() {
    return (_db.select(_db.conversations)
          ..where((c) => c.isHidden.equals(false))
          ..orderBy([(c) => drift.OrderingTerm.desc(c.lastActive)]))
        .watch()
        .map((list) {
      return list
          .map((c) => Conversation(
                id: c.id,
                userAId: c.userAId,
                userBId: c.userBId,
                blocked: c.blocked,
                createdAt: c.createdAt,
                lastActive: c.lastActive,
              ))
          .toList();
    });
  }

  Future<void> refreshConversations() async {
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
                isHidden: false,
                // We do NOT overwrite isHidden here so that locally hidden chats stay hidden until a new message arrives.
                // drift.InsertMode.insertOrReplace would overwrite it. 
                // So we'll update selectively or just rely on a custom query.
              )),
          mode: drift.InsertMode.insertOrIgnore, // Only insert if missing. (Wait, lastActive updates won't be applied).
        );
      });
      
      // Update lastActive for existing conversations without affecting isHidden
      for (var c in conversations) {
        await (_db.update(_db.conversations)..where((tbl) => tbl.id.equals(c.id))).write(
          db.ConversationsCompanion(
            lastActive: drift.Value(c.lastActive),
            blocked: drift.Value(c.blocked),
          ),
        );
      }
    } catch (e) {
      // Ignore network errors on background refresh
    }
  }

  Future<List<Conversation>> getConversations() async {
    // Kept for backward compatibility if needed, but mostly UI will use watchConversations.
    final offline = await (_db.select(_db.conversations)..where((c) => c.isHidden.equals(false))).get();
    return offline
        .map((c) => Conversation(
              id: c.id,
              userAId: c.userAId,
              userBId: c.userBId,
              blocked: c.blocked,
              createdAt: c.createdAt,
              lastActive: c.lastActive,
            ))
        .toList();
  }

  Future<void> hideConversations(List<String> ids) async {
    await _db.transaction(() async {
      for (var id in ids) {
        await (_db.update(_db.conversations)..where((c) => c.id.equals(id))).write(
          const db.ConversationsCompanion(isHidden: drift.Value(true)),
        );
      }
    });
  }

  Future<void> clearConversation(String conversationId) async {
    // Delete all messages in the conversation locally
    await (_db.delete(_db.messages)..where((m) => m.conversationId.equals(conversationId))).go();
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
    // 1. Optimistic UI: Insert pending message to chat queue
    final pendingId = const Uuid().v4();
    final now = DateTime.now();
    final tempMsg = db.PendingChatMessage(
      id: pendingId,
      conversationId: conversationId,
      body: body,
      replyToId: replyToId,
      createdAt: now,
    );
    await _db.into(_db.pendingChatMessages).insert(tempMsg);

    final uiMsg = db.Message(
      id: pendingId,
      conversationId: conversationId,
      senderId: senderId,
      body: body,
      isDeleted: false,
      sentAt: now,
      replyToId: replyToId,
      editedAt: null,
      status: 'pending',
    );
    await _db.into(_db.messages).insert(uiMsg);

    // 2. Perform API call asynchronously
    try {
      final msg = await _api.sendMessage(conversationId, body, replyToId: replyToId);
      
      // 3. On success, delete pending and insert real message
      await _db.transaction(() async {
        await (_db.delete(_db.pendingChatMessages)..where((t) => t.id.equals(pendingId))).go();
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
        // Unhide conversation if it was hidden
        await (_db.update(_db.conversations)..where((c) => c.id.equals(msg.conversationId))).write(
          const db.ConversationsCompanion(isHidden: drift.Value(false)),
        );
      });
    } catch (e) {
      // 4. On error, leave it in the PendingChatMessages queue.
      // Status remains 'pending' in Messages table, will be retried later.
    }
  }

  Future<void> flushOfflineQueue(String senderId) async {
    final pending = await _db.select(_db.pendingChatMessages).get();
    for (final p in pending) {
      try {
        final msg = await _api.sendMessage(p.conversationId, p.body, replyToId: p.replyToId);
        await _db.transaction(() async {
          await (_db.delete(_db.pendingChatMessages)..where((t) => t.id.equals(p.id))).go();
          await (_db.delete(_db.messages)..where((t) => t.id.equals(p.id))).go();
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
        // Skip on error, retry next time
      }
    }
  }

  Future<void> syncMissedMessages() async {
    try {
      final mostRecentMsg = await (_db.select(_db.messages)
            ..orderBy([(t) => drift.OrderingTerm.desc(t.sentAt)])
            ..limit(1))
          .getSingleOrNull();

      final since = mostRecentMsg?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final messages = await _api.syncMissedMessages(since);
      
      if (messages.isNotEmpty) {
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
                  status: 'sent',
                )),
            mode: drift.InsertMode.insertOrReplace,
          );
        });
      }
    } catch (e) {
      // Ignore network errors
    }
  }

  Future<void> readConversation(String conversationId) async {
    try {
      await _api.readConversation(conversationId);
    } catch (e) {
      // Ignore network errors
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
      // Unhide conversation if it was hidden
      await (_db.update(_db.conversations)..where((c) => c.id.equals(msg.conversationId))).write(
        const db.ConversationsCompanion(isHidden: drift.Value(false)),
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
        isHidden: false,
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
  }
}
