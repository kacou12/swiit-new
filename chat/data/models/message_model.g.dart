// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as int,
      chat_room_id: json['chat_room_id'] as int,
      sender_id: json['sender_id'] as int,
      created_at: DateTime.parse(json['created_at'] as String),
      content: json['content'] as String,
      sender: json['sender'] == null
          ? null
          : UserModel.fromJson(jsonEncode(json['sender'])),
      chatRoom: json['chat_room'] == null
          ? null
          : ChatRoom.fromJson(json['chat_room'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room_id': instance.chat_room_id,
      'sender_id': instance.sender_id,
      'content': instance.content,
      'created_at': instance.created_at.toIso8601String(),
      'sender': instance.sender,
      'chatRoom': instance.chatRoom
    };
