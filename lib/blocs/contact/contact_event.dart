part of 'contact_bloc.dart';

@immutable
abstract class ContactEvent {}

class ContactInitialEvent extends ContactEvent {}

class SearchContactEvent extends ContactEvent {
  final String keyword;

  SearchContactEvent({required this.keyword});
}

class LoadContactsEvent extends ContactEvent {}

class AddContactEvent extends ContactEvent {
  final String contactId;

  AddContactEvent({required this.contactId});
}

class RefreshContactsEvent extends ContactEvent {}
