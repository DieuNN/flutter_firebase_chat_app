part of 'conversation_bloc.dart';

@immutable
abstract class ConversationEvent {}

class ConversationInitEvent extends ConversationEvent {}

class ConversationsLoadEvent extends ConversationEvent {
  final String uid;

  ConversationsLoadEvent({required this.uid});
}

class ConversationInfoLoadEvent extends ConversationEvent {}
