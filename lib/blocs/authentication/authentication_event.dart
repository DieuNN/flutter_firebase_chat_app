part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class SignInInitialEvent extends AuthenticationEvent {}

class StartSignInEvent extends AuthenticationEvent {
  final SocialLoginProvider provider;
  final String? email;
  final String? password;

  StartSignInEvent({required this.provider, this.email, this.password});
}

class StartSignOutEvent extends AuthenticationEvent {}

class StartCreateAccountEvent extends AuthenticationEvent {
  final String email;
  final String password;

  StartCreateAccountEvent({required this.email, required this.password});
}

class StartUpdateAccountEvent extends AuthenticationEvent {
  final File? file;
  final String name;
  final String email;
  final String password;

  StartUpdateAccountEvent(
      {required this.file,
      required this.name,
      required this.email,
      required this.password});
}
