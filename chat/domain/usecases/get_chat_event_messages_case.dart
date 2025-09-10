// domain/usecases/subscription_use_case.dart

import 'package:dartz/dartz.dart';
import 'package:swiit/src/core/errors/failure.dart';
import 'package:swiit/src/core/usecase/usecase.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_message.dart';
import 'package:swiit/src/features/chat/domain/repositories/chat_repository.dart';

class GetChatEventMessagesCase extends UseCase<List<ChatMessage>, String> {
  final ChatRepository repository;

  GetChatEventMessagesCase(this.repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(String params) async {
    return await repository.getChatEventMessages(params);
  }
}
