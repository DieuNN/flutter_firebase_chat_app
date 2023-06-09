part of 'message_bloc.dart';

@immutable
abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessagesLoadInProgressState extends MessageState {}

class MessagesLoadSuccessState extends MessageState {
  final List<MessageContent> messages;
  final Stream<cloud.QuerySnapshot<Map<String, dynamic>>>? snapshot;

  MessagesLoadSuccessState({this.snapshot, required this.messages});
}

class MessagesLoadFailureState extends MessageState {
  final String exception;

  MessagesLoadFailureState({required this.exception});
}

class MessageTextSendInProgressState extends MessageState {}

class MessageTextSendSuccessState extends MessageState {
  final Stream<cloud.QuerySnapshot<Map<String, dynamic>>>? snapshot;

  MessageTextSendSuccessState({this.snapshot});
}

class MessageTextSendFailureState extends MessageState {
  final String error;

  MessageTextSendFailureState({required this.error});
}

class MessageImageSendInProgressState extends MessageState {}

class MessageImageSendSuccessState extends MessageState {
  final Stream<cloud.QuerySnapshot<Map<String, dynamic>>>? snapshot;

  MessageImageSendSuccessState({this.snapshot});
}

class MessageImageSendFailureState extends MessageState {
  final String error;

  MessageImageSendFailureState({required this.error});
}
