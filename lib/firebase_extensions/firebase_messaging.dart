import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/firebase_extensions/firebase_app.dart';
import 'package:chat_app/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> _initLocalMessaging() async {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
          android: AndroidInitializationSettings("app_logo"),
          iOS: DarwinInitializationSettings()),
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future<void> showNotification(
      {required String title, required String message}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (appKey.currentContext != null) {
      appKey.currentContext!
          .read<ConversationBloc>()
          .add(ConversationsLoadEvent(uid: uid!));
    }
    const androidDetail = AndroidNotificationDetails("...", "...");
    const iosDetail = DarwinNotificationDetails(
      subtitle: "Subtitle",
    );
    const notificationDetails =
        NotificationDetails(android: androidDetail, iOS: iosDetail);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
    );
  }

  static void sendPushNotification(
      {required String? fromUid,
      required String? toUid,
      required String title,
      required String message}) async {
    if (toUid == null) {
      return;
    }
    model.User? userInfo;
    if (fromUid == FirebaseAuth.instance.currentUser?.uid) {
      userInfo = await FirebaseFirestoreExtensions.getUserInfoByUid(toUid);
      log("A");
    } else {
      log("B");
      userInfo = await FirebaseFirestoreExtensions.getUserInfoByUid(fromUid!);
    }

    if (userInfo == null) {
      return;
    }
    final body = {
      "data": {
        "title": title,
        "message": message,
      },
      "to": userInfo.fcmToken
    };
    log(jsonEncode(body));
    final client = http.Client();
    final result = await client.post(Uri.parse(dotenv.env['FCM_URL']!),
        body: jsonEncode(body),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'key=${dotenv.env['SERVER_KEY']}'
        });
    log(result.body);
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseAppExtensions.ensureInitialized();
  FirebaseMessagingExtensions.showNotification(
      title: message.data['title'], message: message.data['message']);
}
