import 'package:json_annotation/json_annotation.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_message.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_room.dart';
import 'dart:convert';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends ChatMessage {
  const MessageModel(
      {required super.id,
      required super.chat_room_id,
      required super.sender_id,
      required super.content,
      required super.created_at,
      super.sender,
      super.chatRoom});

  @override
  List<Object?> get props =>
      [id, chat_room_id, sender_id, content, created_at, sender, chatRoom];

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
