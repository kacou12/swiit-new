import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_payload.g.dart';

@JsonSerializable()
class MessagePayload extends Equatable {
  final int chat_room_id, sender_id;
  final String content;

  const MessagePayload({
    required this.chat_room_id,
    required this.sender_id,
    required this.content,
  });

  @override
  List<Object?> get props => [chat_room_id, sender_id, content];

  factory MessagePayload.fromJson(Map<String, dynamic> json) =>
      _$MessagePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$MessagePayloadToJson(this);
}
