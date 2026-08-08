import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class MessageRequest with _$MessageRequest {

  const factory MessageRequest({
    required String id,
    @JsonKey(name: 'from_user_id') required String fromUserId,
    @JsonKey(name: 'to_user_id') required String toUserId,
    required String status,
    @JsonKey(name: 'first_message') required String firstMessage,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MessageRequest;

  factory MessageRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageRequestFromJson(json);
}

@freezed
abstract class Conversation with _$Conversation {

  const factory Conversation({
    required String id,
    @JsonKey(name: 'user_a_id') required String userAId,
    @JsonKey(name: 'user_b_id') required String userBId,
    required bool blocked,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_active') required DateTime lastActive,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'user_a_last_read_at') DateTime? userALastReadAt,
    @JsonKey(name: 'user_b_last_read_at') DateTime? userBLastReadAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class Message with _$Message {

  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String body,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
    @JsonKey(name: 'sent_at') required DateTime sentAt,
    @JsonKey(name: 'reply_to_id') String? replyToId,
    @JsonKey(name: 'edited_at') DateTime? editedAt,
    @Default('sent') String status,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
