// data/repositories/event_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:swiit/src/core/errors/failure.dart';
import 'package:swiit/src/core/network/network_info.dart';
import 'package:swiit/src/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:swiit/src/features/chat/data/models/message_model.dart';
import 'package:swiit/src/features/chat/data/models/message_payload.dart';
import 'package:swiit/src/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  // final EventLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    // required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MessageModel>>> getChatEventMessages(
      String roomIdPayload) async {
    if (await networkInfo.isConnected) {
      try {
        final messages =
            await remoteDataSource.getChatEventMessages(roomIdPayload);
        // print(remoteEvents);
        // localDataSource.cacheEvents(remoteEvents);
        return Right(messages);
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> addChatEventMessage(
      MessagePayload payload) async {
    if (await networkInfo.isConnected) {
      try {
        final eventSubscribers =
            await remoteDataSource.addChatEventMessage(payload);
        print(eventSubscribers);
        return Right(eventSubscribers);
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: "No internet connection"));
    }
  }
}
