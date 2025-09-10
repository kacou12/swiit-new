class RoomMessageModel {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  const RoomMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  // Conversion depuis un JSON
  factory RoomMessageModel.fromJson(Map<String, dynamic> json) {
    return RoomMessageModel(
      id: json['id'] as int,
      chatRoomId: json['chatRoomId'] as int,
      senderId: json['senderId'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Conversion vers un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, chatRoomId, senderId, content, createdAt];
}
