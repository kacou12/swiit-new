import 'package:equatable/equatable.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/auth/domain/entities/user.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_room.dart';

class ChatMessage extends Equatable {
  final int id, chat_room_id, sender_id;
  final String content;
  final DateTime created_at;
  final UserModel? sender;
  final ChatRoom? chatRoom;

  const ChatMessage({
    required this.id,
    required this.chat_room_id,
    required this.sender_id,
    required this.content,
    required this.created_at,
    this.sender,
    this.chatRoom,
  });

  @override
  List<Object?> get props =>
      [id, chat_room_id, sender_id, content, created_at, sender];
}
