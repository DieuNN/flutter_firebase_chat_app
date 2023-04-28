import 'dart:developer';

import 'package:chat_app/firebase_extensions/firebase_app.dart';
import 'package:chat_app/firebase_extensions/firebase_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


extension FirebaseMessagingExtensions on  FirebaseMessaging {
  static Future<void> initFirebaseMessaging() async {
    await FirebaseAppExtensions.ensureInitialized();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      log(token);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      FirebaseFirestoreExtensions
          .updateUserFcmToken(uid: user.uid, newToken: token);
    });
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}
