import 'package:equatable/equatable.dart';
import 'package:swiit/src/features/chat/domain/entities/chat_message.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_state.dart';

class ChatState extends Equatable {
  final Status chatEventMessagesStatus;
  final List<ChatMessage> eventChatMessages;

  final String? error;

  const ChatState({
    this.chatEventMessagesStatus = Status.initial,
    this.eventChatMessages = const [],
    this.error,
  });

  ChatState copyWith({
    chatEventMessagesStatus,
    eventChatMessages,
    String? error,
  }) {
    return ChatState(
      chatEventMessagesStatus:
          chatEventMessagesStatus ?? this.chatEventMessagesStatus,
      error: error ?? this.error,
      eventChatMessages: eventChatMessages ?? this.eventChatMessages,
    );
  }

  @override
  List<Object?> get props =>
      [chatEventMessagesStatus, error, eventChatMessages];
}

class CoachingInitial extends ChatState {}
