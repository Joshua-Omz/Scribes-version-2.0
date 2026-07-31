// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageRequest _$MessageRequestFromJson(Map<String, dynamic> json) =>
    _MessageRequest(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      status: json['status'] as String,
      firstMessage: json['first_message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MessageRequestToJson(_MessageRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from_user_id': instance.fromUserId,
      'to_user_id': instance.toUserId,
      'status': instance.status,
      'first_message': instance.firstMessage,
      'created_at': instance.createdAt.toIso8601String(),
    };

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      userAId: json['user_a_id'] as String,
      userBId: json['user_b_id'] as String,
      blocked: json['blocked'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActive: DateTime.parse(json['last_active'] as String),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_a_id': instance.userAId,
      'user_b_id': instance.userBId,
      'blocked': instance.blocked,
      'created_at': instance.createdAt.toIso8601String(),
      'last_active': instance.lastActive.toIso8601String(),
    };

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  body: json['body'] as String,
  isDeleted: json['is_deleted'] as bool,
  sentAt: DateTime.parse(json['sent_at'] as String),
  replyToId: json['reply_to_id'] as String?,
  editedAt: json['edited_at'] == null
      ? null
      : DateTime.parse(json['edited_at'] as String),
  status: json['status'] as String? ?? 'sent',
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'body': instance.body,
  'is_deleted': instance.isDeleted,
  'sent_at': instance.sentAt.toIso8601String(),
  'reply_to_id': instance.replyToId,
  'edited_at': instance.editedAt?.toIso8601String(),
  'status': instance.status,
};
