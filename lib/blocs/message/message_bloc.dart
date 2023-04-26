import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:chat_app/network/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:meta/meta.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<MessageEvent>((event, emit) {
      emit(MessageInitial());
    });
    on<MessageLoadEvent>((event, emit) async {
      emit(MessagesLoadInProgressState());
      try {
        final messages =
            await FirebaseFirestore().getMessages(event.conversation);
        emit(MessagesLoadSuccessState(messages: messages));
      } catch (e) {
        log(e.toString());
        emit(MessagesLoadFailureState(exception: e.toString()));
      }
    }, transformer: sequential());

    on<MessageTextSendEvent>((event, emit) async {
      emit(MessageTextSendInProgressState());
      try {
        log("Message sending called in bloc");
        log("???");
        log("Message sending called in bloc, map: ${event.conversation.toMap()}");
        log("Message sending called in bloc, sender: ${event.conversation.fromUid}");
        log("Message sending called in bloc, receiver: ${event.conversation.toUid}");

        await FirebaseFirestore().sendMessage(
            messageType: MessageType.text,
            messageContent: MessageContent(
              timeStamp: cloud.Timestamp.now(),
              content: event.content,
              type: "text",
              senderUid: event.sender,
            ),
            conversation: event.conversation);
        final snapshot = await FirebaseFirestore().getMessagesSnapshots(event.conversation);
        emit(MessageTextSendSuccessState(snapshot: snapshot));
      } catch (e) {
        log(e.toString());
        emit(MessageTextSendFailureState(error: e.toString()));
      }
    }, transformer: sequential());
  }
}
