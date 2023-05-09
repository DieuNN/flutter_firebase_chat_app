import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'conversation_event.dart';

part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(ConversationInitial()) {
    on<ConversationEvent>((event, emit) {
      emit(ConversationInitial());
    });
    on<ConversationInitEvent>((event, emit) {
      emit(ConversationInitial());
    }, transformer: sequential());
    on<ConversationsLoadEvent>((event, emit) async {
      try {
        emit(ConversationsLoadInProgressState());
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final conversations =
            await FirebaseFirestoreExtensions.getConversations(uid: uid);
        emit(ConversationsLoadSuccessState(conversations: conversations));
      } catch (e) {
        log(e.toString());
        emit(ConversationsLoadFailureState(error: e.toString()));
      }
    }, transformer: sequential());
  }
}
