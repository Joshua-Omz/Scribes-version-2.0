import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/network/api_client.dart';
import '../domain/message.dart';
import '../domain/contact.dart';

final messageApiProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MessageApi(apiClient);
});

class MessageApi {
  final Dio _dio;

  MessageApi(this._dio);

  Future<MessageRequest> sendRequest(String toUserId, String firstMessage) async {
    final response = await _dio.post('/message-requests', data: {
      'to_user_id': toUserId,
      'first_message': firstMessage,
    });
    return MessageRequest.fromJson(response.data);
  }

  Future<List<MessageRequest>> getPendingRequests() async {
    final response = await _dio.get('/message-requests');
    if (response.data == null) return [];
    final List<dynamic> data = response.data is List ? response.data as List<dynamic> : [];
    return data.map((json) => MessageRequest.fromJson(json)).toList();
  }

  Future<Conversation> approveRequest(String requestId) async {
    final response = await _dio.post('/message-requests/$requestId/approve');
    return Conversation.fromJson(response.data);
  }

  Future<void> rejectRequest(String requestId) async {
    await _dio.post('/message-requests/$requestId/reject');
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get('/conversations');
    if (response.data == null) return [];
    final List<dynamic> data = response.data is List ? response.data as List<dynamic> : [];
    return data.map((json) => Conversation.fromJson(json)).toList();
  }

  Future<Conversation> getOrCreateDirectConversation(String toUserId) async {
    final response = await _dio.post('/conversations/direct', data: {
      'to_user_id': toUserId,
    });
    return Conversation.fromJson(response.data);
  }

  Future<List<Contact>> searchContacts(String query) async {
    final response = await _dio.get('/contacts/search', queryParameters: {
      'q': query,
    });
    if (response.data == null) return [];
    final List<dynamic> data = response.data is List ? response.data as List<dynamic> : [];
    return data.map((json) => Contact.fromJson(json)).toList();
  }

  Future<List<Message>> getMessages(String conversationId, {DateTime? cursorTs, int limit = 50}) async {
    final response = await _dio.get('/conversations/$conversationId/messages', queryParameters: {
      if (cursorTs != null) 'cursor_ts': cursorTs.toIso8601String(),
      'limit': limit,
    });
    if (response.data == null) return [];
    final List<dynamic> data = response.data is List ? response.data as List<dynamic> : [];
    return data.map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> sendMessage(String conversationId, String body, {String? replyToId}) async {
    final response = await _dio.post('/conversations/$conversationId/messages', data: {
      'body': body,
      if (replyToId != null) 'reply_to_id': replyToId,
    });
    return Message.fromJson(response.data);
  }

  Future<Message> updateMessage(String conversationId, String messageId, String body) async {
    final response = await _dio.patch('/conversations/$conversationId/messages/$messageId', data: {
      'body': body,
    });
    return Message.fromJson(response.data);
  }

  Future<void> blockConversation(String conversationId) async {
    await _dio.post('/conversations/$conversationId/block');
  }

  Future<void> softDeleteMessage(String messageId) async {
    await _dio.delete('/messages/$messageId');
  }

  Future<Conversation> readConversation(String conversationId) async {
    final response = await _dio.post('/conversations/$conversationId/read');
    return Conversation.fromJson(response.data);
  }

  Future<List<Message>> syncMissedMessages(DateTime since) async {
    final response = await _dio.get('/dm/sync', queryParameters: {
      'since': since.toUtc().toIso8601String(),
    });
    if (response.data == null) return [];
    final List<dynamic> data = response.data is List ? response.data as List<dynamic> : [];
    return data.map((json) => Message.fromJson(json)).toList();
  }

  /// Returns a stream of real-time messages for the given conversation.
  Stream<Message> streamMessages(String conversationId) async* {
    final response = await _dio.get<ResponseBody>(
      '/conversations/$conversationId/stream',
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream;
    
    // Parse SSE format
    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      // Basic SSE parsing (looking for 'data: {json}\n\n')
      final lines = text.split('\n');
      for (final line in lines) {
        if (line.startsWith('data:')) {
          final dataStr = line.substring(5).trim();
          if (dataStr.isNotEmpty) {
            try {
              final json = jsonDecode(dataStr);
              yield Message.fromJson(json);
            } catch (e) {
              // ignore malformed chunks
            }
          }
        }
      }
    }
  }
}
