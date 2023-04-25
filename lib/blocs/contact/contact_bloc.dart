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
    on<ContactInitialEvent>((event, emit) {});
    on<LoadContactsEvent>((event, emit) async {
      emit(LoadContactsInProgressState());
      try {
        final uid = auth.FirebaseAuth.instance.currentUser!.uid;
        final contacts = await cloud.FirebaseFirestore().getUserContacts(uid);
        for (var element in contacts) {
        }
        emit(LoadContactsSuccessState(contacts: contacts));
      } catch (e) {
        log(e.toString());
        emit(LoadContactsFailureState(errorMessage: e.toString()));
      }
    });
    on<SearchContactEvent>((event, emit) async {
      emit(ContactSearchInProgressState());
      try {
        final result = await cloud.FirebaseFirestore()
            .findContact(contactEmail: event.keyword);
        emit(ContactSearchSuccessState(contacts: result));
        log(result.length.toString());
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
