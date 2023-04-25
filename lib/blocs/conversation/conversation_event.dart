part of 'conversation_bloc.dart';

@immutable
abstract class ConversationEvent {}

class ConversationInitEvent extends ConversationEvent {}

class ConversationsLoadEvent extends ConversationEvent {
}

class ConversationInfoLoadEvent extends ConversationEvent {}
