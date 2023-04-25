part of 'conversation_bloc.dart';

@immutable
abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationsLoadInProgressState extends ConversationState {}

class ConversationsLoadSuccessState extends ConversationState {
  final List<Conversation> conversations;

  ConversationsLoadSuccessState({required this.conversations});
}

class ConversationsLoadFailureState extends ConversationState {
  final String error;

  ConversationsLoadFailureState({required this.error});
}

class ConversationInfoLoadInProgressState extends ConversationState {}

class ConversationInfoLoadSuccessState extends ConversationState {}

class ConversationInfoLoadFailureState extends ConversationState {}
