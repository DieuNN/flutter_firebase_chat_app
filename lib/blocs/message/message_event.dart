part of 'message_bloc.dart';

@immutable
abstract class MessageEvent {}

class MessageInitEvent extends MessageEvent {}

class MessageLoadEvent extends MessageEvent {
  final String toUid;

  MessageLoadEvent({required this.toUid});
}

class MessageTextSendEvent extends MessageEvent {
  final String content;
  final Conversation conversation;

  MessageTextSendEvent({required this.content, required this.conversation});
}
