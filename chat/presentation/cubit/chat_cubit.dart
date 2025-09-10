// presentation/cubit/coaching_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:swiit/src/features/chat/data/models/message_model.dart';
import 'package:swiit/src/features/chat/data/models/message_payload.dart';
import 'package:swiit/src/features/chat/domain/usecases/add_chat_event_message_case.dart';
import 'package:swiit/src/features/chat/domain/usecases/get_chat_event_messages_case.dart';
import 'package:swiit/src/features/chat/presentation/cubit/chat_state.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_state.dart';
import 'package:swiit/src/features/events/presentation/cubit/event_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final AddChatEventMessageCase addChatEventMessageCase;
  final GetChatEventMessagesCase getChatEventMessagesCase;

  ChatCubit({
    required this.addChatEventMessageCase,
    required this.getChatEventMessagesCase,
  }) : super(const ChatState());

  Future<void> fetchChatEventMessages(String params) async {
    emit(state.copyWith(
      chatEventMessagesStatus: Status.loading,
    ));

    //
    final failureOrEvent = await getChatEventMessagesCase(params);
    failureOrEvent.fold(
      (failure) => {
// emit(state.copyWith(
//         chatEventMessagesStatus: Status.error,
//       )
//       )
      },
      (chatMessages) => emit(state.copyWith(
        eventChatMessages: chatMessages,
        chatEventMessagesStatus: Status.success,
      )),
    );
  }

  Future<void> sendEventMessage(MessagePayload payload) async {
    // emit(const EventCreationLoading());
    // emit(state.copyWith(eventStatus: Status.loading));
    final failureOrEvent = await addChatEventMessageCase(payload);
    failureOrEvent.fold(
      (failure) => {
        // emit(state.copyWith(error: _mapFailureToMessage(failure)))
      },
      (message) {
        final newMessages = [...state.eventChatMessages, message];
        emit(state.copyWith(eventChatMessages: newMessages));
      },
    );
  }
}
