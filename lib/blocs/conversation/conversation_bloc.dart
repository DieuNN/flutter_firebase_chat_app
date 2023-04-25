import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/network/firebase_firestore.dart';
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
        final conversations = await FirebaseFirestore().getConversations();
        emit(ConversationsLoadSuccessState(conversations: conversations));
      } catch (e) {
        emit(ConversationsLoadFailureState(error: e.toString()));
      }
    }, transformer: sequential());
  }
}
