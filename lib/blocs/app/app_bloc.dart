import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/firebase_extensions/firebase_app.dart';
import 'package:chat_app/firebase_extensions/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitialState()) {
    on<AppEvent>((event, emit) {});

    on<AppInitialEvent>((event, emit) async {
      emit(AppInitializingState());
      try {

        await FirebaseAppExtensions.ensureInitialized();
        await FirebaseMessagingExtensions.initFirebaseMessaging();
        User? user = FirebaseAuth.instance.currentUser;
        emit(AppInitialSuccessState(user: user));
      } catch (e) {
        log(e.toString());
        emit(AppInitialFailureState());
      }
    }, transformer: sequential());
  }
}
