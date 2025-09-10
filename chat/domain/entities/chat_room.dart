import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:swiit/src/features/auth/domain/entities/user.dart';

part 'chat_room.g.dart';

@JsonSerializable()
class ChatRoom extends Equatable {
  final int id;
  final String room_name;

  const ChatRoom({
    required this.id,
    required this.room_name,
  });

  @override
  List<Object?> get props => [id, room_name];

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
}
