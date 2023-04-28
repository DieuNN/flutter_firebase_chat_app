import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:chat_app/firebase_extensions/firebase_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as cloud_messaging;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:firebase_messaging/firebase_messaging.dart';

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
        // FirebaseMessaging messaging = FirebaseMessaging.instance;
        // log((await messaging.getToken()).toString());
        //
        // NotificationSettings settings = await messaging.requestPermission(
        //   alert: true,
        //   announcement: false,
        //   badge: true,
        //   carPlay: false,
        //   criticalAlert: false,
        //   provisional: false,
        //   sound: true,
        // );
        // log('User granted permission: ${settings.authorizationStatus}');
        // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //   log("ALO");
        //   log('Got a message whilst in the foreground!');
        //   log('Message data: ${message.data}');
        //
        //   if (message.notification != null) {
        //     log('Message also contained a notification: ${message.notification}');
        //   }
        // });
        User? user = FirebaseAuth.instance.currentUser;
        emit(AppInitialSuccessState(user: user));
      } catch (e) {
        log(e.toString());
        emit(AppInitialFailureState());
      }

    }, transformer: sequential());
  }
}
