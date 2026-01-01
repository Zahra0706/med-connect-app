import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  final int id;
  final int patient;
  final int doctor;
  @JsonKey(name: 'patient_name')
  final String patientName;
  @JsonKey(name: 'doctor_name')
  final String doctorName;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'last_message_at')
  final String lastMessageAt;
  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;
  @JsonKey(name: 'unread_count')
  final int? unreadCount;

  ConversationModel({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.patientName,
    required this.doctorName,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
    this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) => _$ConversationModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);
}
