import 'dart:developer';

import 'package:chat_app/firebase_extensions/firebase_app.dart';
import 'package:chat_app/firebase_extensions/firebase_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/model/entity/user.dart' as model;

extension FirebaseMessagingExtensions on FirebaseMessaging {
  static FirebaseMessaging instance = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initFirebaseMessaging() async {
    await FirebaseAppExtensions.ensureInitialized();
    await _initLocalMessaging();
    instance.onTokenRefresh.listen((token) async {
      log(token);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      FirebaseFirestoreExtensions.updateUserFcmToken(
          uid: user.uid, newToken: token);
    });
    FirebaseMessaging.onMessage.listen((event) {
      showNotification(
          title: event.data['title'], message: event.data['message']);
    });
  }

  static Future<void> _initLocalMessaging() async {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("app_logo"),
      ),
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future<void> showNotification(
      {required String title, required String message}) async {
    const detail = AndroidNotificationDetails("...", "...");
    const notificationDetails = NotificationDetails(android: detail);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
    );
  }

  static void _sendPushNotification(
      {required String fromUid,
      required String toUid,
      required String title,
      required String message}) async {
    final userInfo = await FirebaseFirestoreExtensions.getUserInfoByUid(toUid);
    final body = {
      "data": {
        "title": title,
        "message": message,
      },
      "to": userInfo?.fcmToken
    };
    final client = http.Client();
    await client.post(Uri.parse(dotenv.env['FCM_URL']!), body: body, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'key=${dotenv.env['FCM_URL']}'
    });
  }

  static Future<void> addMessageListener({String? uid}) async {
    if (uid == null) {
      return;
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}
