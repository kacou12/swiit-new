import 'package:dartz/dartz.dart';
import 'package:swiit/src/core/errors/failure.dart';
import 'package:swiit/src/features/chat/data/models/message_model.dart';
import 'package:swiit/src/features/chat/data/models/message_payload.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<MessageModel>>> getChatEventMessages(
      String roomIdPayload);
  Future<Either<Failure, MessageModel>> addChatEventMessage(
      MessagePayload payload);
}
