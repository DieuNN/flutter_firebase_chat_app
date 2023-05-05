import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/firebase_extensions/firebase_messaging.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
            await FirebaseFirestoreExtensions.getMessages(event.conversation);
        final snapshot = await FirebaseFirestoreExtensions.getMessagesSnapshots(
            event.conversation);
        emit(MessagesLoadSuccessState(messages: messages, snapshot: snapshot));
      } catch (e) {
        log(e.toString());
        emit(MessagesLoadFailureState(exception: e.toString()));
      }
    }, transformer: sequential());

    on<MessageTextSendEvent>((event, emit) async {
      emit(MessageTextSendInProgressState());
      try {
        await FirebaseFirestoreExtensions.sendMessage(
            messageContent: MessageContent(
              timeStamp: cloud.Timestamp.now(),
              content: event.content,
              type: "text",
              senderUid: event.sender,
            ),
            conversation: event.conversation);
        final snapshot = await FirebaseFirestoreExtensions.getMessagesSnapshots(
            event.conversation);
        final currentUid = FirebaseAuth.instance.currentUser!.uid;
        if (currentUid != event.conversation.fromUid) {
          FirebaseMessagingExtensions.sendPushNotification(
              fromUid: event.conversation.fromUid,
              toUid: event.conversation.toUid,
              title: event.conversation.toName ?? "New message",
              message: event.content);
        } else {
          FirebaseMessagingExtensions.sendPushNotification(
              toUid: event.conversation.fromUid,
              fromUid: event.conversation.toUid,
              title: event.conversation.fromName ?? "New message",
              message: event.content);
        }
        emit(MessageTextSendSuccessState(snapshot: snapshot));
      } catch (e) {
        log(e.toString());
        emit(MessageTextSendFailureState(error: e.toString()));
      }
    }, transformer: sequential());
    on<MessageImageSendEvent>((event, emit) async {
      emit(MessageImageSendInProgressState());
      try {
        await FirebaseFirestoreExtensions.sendMessage(
          conversation: event.conversation,
          messageContent: event.content,
        );
        final snapshot = await FirebaseFirestoreExtensions.getMessagesSnapshots(
            event.conversation);
        final currentUid = FirebaseAuth.instance.currentUser!.uid;
        if (currentUid != event.conversation.fromUid) {
          FirebaseMessagingExtensions.sendPushNotification(
              fromUid: event.conversation.fromUid,
              toUid: event.conversation.toUid,
              title: event.conversation.fromName ?? "New message",
              message: event.content.content ?? "Has sent an image");
        } else {
          FirebaseMessagingExtensions.sendPushNotification(
              toUid: event.conversation.fromUid,
              fromUid: event.conversation.toUid,
              title: event.conversation.toName ?? "New message",
              message: event.content.content ?? "Has sent an image");
        }

        emit(MessageImageSendSuccessState(snapshot: snapshot));
      } catch (e) {
        log(e.toString());
        emit(MessageImageSendFailureState(error: e.toString()));
      }
    }, transformer: sequential());
  }
}
