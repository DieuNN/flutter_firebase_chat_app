import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/firebase_extensions/firebase_authentication.dart';
import 'package:chat_app/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/firebase_extensions/firebase_storage.dart';
import 'package:chat_app/model/enum/social_login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:meta/meta.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<SignInInitialEvent>(
      (event, emit) async {
        emit(AuthenticationInitialState());
      },
    );
    on<AuthenticationEvent>(
      (event, emit) async {},
      transformer: sequential(),
    );
    on<StartSignInEvent>((event, emit) async {
      emit(SignInInProgressState());
      try {
        if (event.provider == SocialLoginProvider.email) {
          await FirebaseAuthenticationExtensions.signInWithEmailAndPassword(
              event.email!, event.password!);
        }
        if (event.provider == SocialLoginProvider.google) {
          await FirebaseAuthenticationExtensions.signInWithGoogle();
        }
        emit(SignInSuccessState());
      } on FirebaseAuthException catch (e) {
        log(e.toString());
        emit(SignInFailureState(exception: e.toString()));
      }
    }, transformer: sequential());
    on<StartSignOutEvent>(
      (event, emit) async {
        emit(SignOutInProgressState());
        try {
          FirebaseAuthenticationExtensions.signOut();
          emit(SignOutSuccessState());
        } on FirebaseAuthException catch (e) {
          log("Error when log out: $e");
          emit(SignOutFailureState(errorMessage: e.toString()));
        }
      },
    );
    on<StartCreateAccountEvent>(
      (event, emit) async {
        emit(CreateAccountInProgressState());
        try {
          await FirebaseAuthenticationExtensions.createUserWithEmailAndPassword(
            event.email,
            event.password,
            event.name,
          );
          emit(CreateAccountSuccessState());
        } on FirebaseAuthException catch (e) {
          log(e.toString());
          emit(CreateAccountFailureState(errorMessage: e.toString()));
        }
      },
    );
    on<StartUpdateAccountEvent>((event, emit) async {
      emit(UpdateAccountInProgressState());
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (event.file == null) {
          await FirebaseFirestoreExtensions.updateUserProfile(
              email: event.email, uid: uid!, name: event.name);
          await FirebaseAuthenticationExtensions.updateUserCredential(
            email: event.email,
            displayName: event.name,
            password: event.password,
          );
        } else {
          var uploadUrl =
              await FirebaseStorageExtensions.uploadAvatar(event.file!, uid!);
          log("Image uploaded at: $uploadUrl");
          await FirebaseAuthenticationExtensions.updateUserCredential(
            email: event.email,
            displayName: event.name,
            password: event.password,
            profileUrl: uploadUrl,
          );
          await FirebaseFirestoreExtensions.updateUserProfile(
            email: event.email,
            uid: uid,
            name: event.name,
            profilePicture: uploadUrl,
          );
        }
        emit(UpdateAccountSuccessState());
      } on FirebaseAuthException catch (e) {
        // Profile already updated, need to login again to take effects
        if (e.code == "requires-recent-login") {
          emit(UpdateAccountSuccessState());
        }
        emit(UpdateAccountFailureState(errorMessage: e.toString()));
      } catch (e) {
        log(e.toString());
      }
    }, transformer: sequential());
  }
}
