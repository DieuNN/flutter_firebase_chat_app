import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/model/entity/user.dart' as model;
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
        final contacts = await FirebaseFirestoreExtensions.getUserContacts(uid);
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
        final result = await FirebaseFirestoreExtensions
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
        await FirebaseFirestoreExtensions.addContact(contactId: event.contactId);
        emit(AddContactSuccessState());
      } catch (e) {
        emit(AddContactFailureState(errorMessage: e.toString()));
      }
    }, transformer: sequential());
  }
}
