import 'dart:developer';

import 'package:chat_app/blocs/app/app_bloc.dart';
import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/blocs/contact/contact_bloc.dart';
import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/blocs/message/message_bloc.dart';
import 'package:chat_app/blocs/pages/page_bloc.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:chat_app/network/firebase_firestore.dart';
import 'package:chat_app/ui/page/add_contact_page.dart';
import 'package:chat_app/ui/page/message_page.dart';
import 'package:chat_app/ui/page/home_page.dart';
import 'package:chat_app/ui/page/login_page.dart';
import 'package:chat_app/ui/page/sign_up_page.dart';
import 'package:chat_app/utils/animated_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  var binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  if (kIsWeb) {
    FlutterNativeSplash.remove();
    final firebaseApp = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBr-kiWZQhInKiiW-JFkDqHQlfSGgQGj8U",
        appId: "1:320497612221:web:614c125424079fd2510ed4",
        messagingSenderId: "320497612221",
        storageBucket: "gs://chat-app-e6c8a.appspot.com",
        projectId: "chat-app-e6c8a",
      ),
    );
    cloud.FirebaseFirestore.instanceFor(app: firebaseApp);
  }
  await Firebase.initializeApp();

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AppBloc()
            ..add(
              AppInitialEvent(),
            ),
        ),
        BlocProvider(
          create: (context) => AuthenticationBloc()
            ..add(
              SignInInitialEvent(),
            ),
        ),
        BlocProvider(
          create: (context) => PageBloc()..add(ChangePageEvent(screenIndex: 0)),
        ),
        BlocProvider(
          create: (context) => ContactBloc()
            ..add(
              ContactInitialEvent(),
            ),
        ),
        BlocProvider(
          create: (context) => ConversationBloc()
            ..add(
              ConversationInitEvent(),
            ),
        ),
        BlocProvider(
          create: (context) => MessageBloc()
            ..add(
              MessageInitEvent(),
            ),
        ),
      ],
      child: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AppInitialSuccessState) {
            FlutterNativeSplash.remove();
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
              initialRoute: state.user == null ? "/login" : "/",
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) {
                if (settings.name == "/") {
                  return AnimatedRoute.createSlidingUpRoute(HomePage());
                }
                if (settings.name == "/login") {
                  return AnimatedRoute.createSlidingUpRoute(const LoginPage());
                }
                if (settings.name == "/signup") {
                  return AnimatedRoute.createSlidingUpRoute(const SignUpPage());
                }
                if (settings.name == "/add_contact") {
                  final dynamic arguments = settings.arguments;
                  return AnimatedRoute.createSlidingUpRoute(
                    AddContactPage(
                      arguments: arguments,
                    ),
                  );
                }
                if (settings.name == "/chat") {
                  final dynamic arguments = settings.arguments;
                  return AnimatedRoute.createSlidingUpRoute(
                    ConversationPage(args: arguments),
                  );
                }
                // Unknown route
                return AnimatedRoute.createSlidingUpRoute(HomePage());
              },
            );
          }
          return const Placeholder();
        },
      ),
    );
  }
}
