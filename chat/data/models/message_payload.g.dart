// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagePayload _$MessagePayloadFromJson(Map<String, dynamic> json) =>
    MessagePayload(
      chat_room_id: json['chat_room_id'] as int,
      sender_id: json['sender_id'] as int,
      content: json['content'] as String,
    );

Map<String, dynamic> _$MessagePayloadToJson(MessagePayload instance) =>
    <String, dynamic>{
      'chat_room_id': instance.chat_room_id,
      'sender_id': instance.sender_id,
      'content': instance.content,
    };
