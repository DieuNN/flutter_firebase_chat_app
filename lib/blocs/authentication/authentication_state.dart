part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {}

class AuthenticationInitialState extends AuthenticationState {}

class SignInInProgressState extends AuthenticationState {}

class SignInSuccessState extends AuthenticationState {}

class SignInFailureState extends AuthenticationState {
  final String exception;

  SignInFailureState({required this.exception});
}

class SignOutInProgressState extends AuthenticationState {}

class SignOutSuccessState extends AuthenticationState {}

class SignOutFailureState extends AuthenticationState {
  final String errorMessage;

  SignOutFailureState({required this.errorMessage});
}

class CreateAccountInProgressState extends AuthenticationState {}

class CreateAccountSuccessState extends AuthenticationState {}

class CreateAccountFailureState extends AuthenticationState {
  final String errorMessage;

  CreateAccountFailureState({required this.errorMessage});
}

class UpdateAccountInProgressState extends AuthenticationState {}

class UpdateAccountSuccessState extends AuthenticationState {}

class UpdateAccountFailureState extends AuthenticationState {
  final String errorMessage;

  UpdateAccountFailureState({required this.errorMessage});
}

class ForgetPasswordInProgressState extends AuthenticationState {
}

class ForgetPasswordSuccessState extends AuthenticationState {}

class ForgetPasswordFailureState extends AuthenticationState {
  final String? errorMessage;

  ForgetPasswordFailureState({this.errorMessage});
}
