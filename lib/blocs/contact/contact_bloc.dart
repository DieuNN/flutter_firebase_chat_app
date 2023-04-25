import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/model/entity/user.dart' as entity;
import 'package:chat_app/network/firebase_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:meta/meta.dart';

part 'contact_event.dart';

part 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc() : super(ContactInitial()) {
    on<ContactEvent>((event, emit) {});
    on<ContactInitialEvent>((event, emit) {
      log("Contact initial");
      emit(ContactInitial());
    });
    on<LoadContactsEvent>((event, emit) async {
      emit(LoadContactsInProgressState());
      try {
        log("Contact loading");
        final uid = auth.FirebaseAuth.instance.currentUser!.uid;
        final contacts = await cloud.FirebaseFirestore().getUserContacts(uid);
        emit(LoadContactsSuccessState(contacts: contacts));
        log("Contact loaded");
      } catch (e) {
        log(e.toString());
        emit(LoadContactsFailureState(errorMessage: e.toString()));
      }
    });
    on<SearchContactEvent>((event, emit) async {
      emit(ContactSearchInProgressState());
      log("Searching contacts: ");
      try {
        final result = await cloud.FirebaseFirestore()
            .findContact(contactEmail: event.keyword);
        emit(ContactSearchSuccessState(user: result));
      } catch (e) {
        log(e.toString());
        emit(ContactSearchErrorState(errorMessage: e.toString()));
      }
    }, transformer: sequential());
    on<AddContactEvent>((event, emit) async {
      emit(AddContactInProgressState());
      try {
        await cloud.FirebaseFirestore().addContact(contactId: event.contactId);
        emit(AddContactSuccessState());
      } catch (e) {
        emit(AddContactFailureState(errorMessage: e.toString()));
      }
    }, transformer: sequential());
  }
}
