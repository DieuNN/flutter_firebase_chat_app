import 'dart:developer';
import 'dart:io';

import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

extension FirebaseAppExtensions on FirebaseApp {
  static Future<void> ensureInitialized() async {
    if (kIsWeb) {
      await _initFirebaseWebApp();
       return ;
    }

    await _initFirebaseMobileApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }


  static Future<void> _initFirebaseMobileApp() async {
    await Firebase.initializeApp();
  }

  static Future<void> _initFirebaseWebApp() async {
    final firebaseApp = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBr-kiWZQhInKiiW-JFkDqHQlfSGgQGj8U",
        appId: "1:320497612221:web:614c125424079fd2510ed4",
        messagingSenderId: "320497612221",
        storageBucket: "gs://chat-app-e6c8a.appspot.com",
        projectId: "chat-app-e6c8a",
      ),
    );
    FirebaseFirestore.instanceFor(app: firebaseApp);
  }
}
