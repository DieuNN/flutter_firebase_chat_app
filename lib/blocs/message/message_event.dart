part of 'message_bloc.dart';

@immutable
abstract class MessageEvent {}

class MessageInitEvent extends MessageEvent {}

class MessageLoadEvent extends MessageEvent {
  final Conversation conversation;

  MessageLoadEvent({required this.conversation});
}

class MessageTextSendEvent extends MessageEvent {
  final String content;
  final Conversation conversation;
  final String sender;

  MessageTextSendEvent(
      {required this.sender,
      required this.content,
      required this.conversation});
}

class MessageImageSendEvent extends MessageEvent {
  final MessageContent content;
  final Conversation conversation;
  final String sender;
  final File file;

  MessageImageSendEvent(
      {required this.file,
      required this.sender,
      required this.content,
      required this.conversation});
}
