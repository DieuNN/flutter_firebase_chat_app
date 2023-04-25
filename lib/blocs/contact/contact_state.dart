part of 'contact_bloc.dart';

@immutable
abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactSearchInProgressState extends ContactState {}

class ContactSearchSuccessState extends ContactState {
  final List<entity.User> contacts;

  ContactSearchSuccessState({required this.contacts});
}

class ContactSearchErrorState extends ContactState {
  final String errorMessage;

  ContactSearchErrorState({required this.errorMessage});
}

class AddContactInProgressState extends ContactState {}

class AddContactSuccessState extends ContactState {}

class AddContactFailureState extends ContactState {
  final String errorMessage;

  AddContactFailureState({required this.errorMessage});
}

class LoadContactsInProgressState extends ContactState {}

class RefreshContactsInProgressState extends ContactState {}

class RefreshContactsSuccessState extends ContactState {
  final List<entity.User> users;

  RefreshContactsSuccessState({required this.users});
}

class RefreshContactsFailureState extends ContactState {
  final String errorMessage;

  RefreshContactsFailureState(this.errorMessage);
}

class LoadContactsSuccessState extends ContactState {
  final List<entity.User> contacts;

  LoadContactsSuccessState({required this.contacts});
}

class LoadContactsFailureState extends ContactState {
  final String errorMessage;

  LoadContactsFailureState({required this.errorMessage});
}
