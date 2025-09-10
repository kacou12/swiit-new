// domain/usecases/subscription_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:swiit/src/core/errors/failure.dart';
import 'package:swiit/src/core/usecase/usecase.dart';
import 'package:swiit/src/features/chat/data/models/message_payload.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_message.dart';
import 'package:swiit/src/features/chat/domain/repositories/chat_repository.dart';

class AddChatEventMessageCase extends UseCase<ChatMessage, MessagePayload> {
  final ChatRepository repository;

  AddChatEventMessageCase(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(MessagePayload params) async {
    return await repository.addChatEventMessage(params);
  }
}
