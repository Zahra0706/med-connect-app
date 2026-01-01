import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int id;
  final int conversation;
  final int sender;
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'sender_role')
  final String senderRole;
  final String? content;
  final String? file;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'sent_at')
  final String sentAt;
  @JsonKey(name: 'read_at')
  final String? readAt;

  MessageModel({
    required this.id,
    required this.conversation,
    required this.sender,
    required this.senderName,
    required this.senderRole,
    this.content,
    this.file,
    this.fileUrl,
    required this.isRead,
    required this.sentAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
