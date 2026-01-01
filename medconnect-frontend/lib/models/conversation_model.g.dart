// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: (json['id'] as num).toInt(),
      patient: (json['patient'] as num).toInt(),
      doctor: (json['doctor'] as num).toInt(),
      patientName: json['patient_name'] as String,
      doctorName: json['doctor_name'] as String,
      createdAt: json['created_at'] as String,
      lastMessageAt: json['last_message_at'] as String,
      lastMessage: json['last_message'] == null
          ? null
          : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: (json['unread_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient': instance.patient,
      'doctor': instance.doctor,
      'patient_name': instance.patientName,
      'doctor_name': instance.doctorName,
      'created_at': instance.createdAt,
      'last_message_at': instance.lastMessageAt,
      'last_message': instance.lastMessage,
      'unread_count': instance.unreadCount,
    };
