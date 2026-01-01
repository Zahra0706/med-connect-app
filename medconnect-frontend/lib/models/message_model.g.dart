// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num).toInt(),
  conversation: (json['conversation'] as num).toInt(),
  sender: (json['sender'] as num).toInt(),
  senderName: json['sender_name'] as String,
  senderRole: json['sender_role'] as String,
  content: json['content'] as String?,
  file: json['file'] as String?,
  fileUrl: json['file_url'] as String?,
  isRead: json['is_read'] as bool,
  sentAt: json['sent_at'] as String,
  readAt: json['read_at'] as String?,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation': instance.conversation,
      'sender': instance.sender,
      'sender_name': instance.senderName,
      'sender_role': instance.senderRole,
      'content': instance.content,
      'file': instance.file,
      'file_url': instance.fileUrl,
      'is_read': instance.isRead,
      'sent_at': instance.sentAt,
      'read_at': instance.readAt,
    };
