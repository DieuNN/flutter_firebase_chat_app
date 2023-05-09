import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_app.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_firestore.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/model/entity/conversation.dart';
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
    // We need a real device to push notification on IOS
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

  static void postFCMRequest(
      {required String title,
      Conversation? conversation,
      required String message}) async {
    if (conversation == null) {
      return;
    }

    if (conversation.toUid == null || conversation.fromUid == null) {
      return;
    }

    // Determine if current uid is the same as sender uid, if it is, get receiver info and request Firebase
    // to send notification for receiver

    model.User? userInfo;
    if (conversation.fromUid == FirebaseAuth.instance.currentUser?.uid) {
      userInfo = await FirebaseFirestoreExtensions.getUserInfoByUid(
          conversation.toUid!);
    } else {
      userInfo = await FirebaseFirestoreExtensions.getUserInfoByUid(
          conversation.fromUid!);
    }

    if (userInfo == null) {
      return;
    }

    final requestBody = {
      "data": {
        "title": title,
        "message": message,
      },
      "to": userInfo.fcmToken
    };

    final requestHeader = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'key=${dotenv.env['SERVER_KEY']}'
    };

    await http.Client().post(
      Uri.parse(dotenv.env['FCM_URL']!),
      body: jsonEncode(requestBody),
      headers: requestHeader,
    );
  }
}


