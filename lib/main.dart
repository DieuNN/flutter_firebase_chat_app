
import 'package:chat_app/blocs/app/app_bloc.dart';
import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/blocs/contact/contact_bloc.dart';
import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/blocs/message/message_bloc.dart';
import 'package:chat_app/blocs/pages/page_bloc.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_app.dart';
import 'package:chat_app/extensions/firebase_extensions/firebase_messaging.dart';
import 'package:chat_app/ui/page/add_contact_page.dart';
import 'package:chat_app/ui/page/message_page.dart';
import 'package:chat_app/ui/page/home_page.dart';
import 'package:chat_app/ui/page/login_page.dart';
import 'package:chat_app/ui/page/sign_up_page.dart';
import 'package:chat_app/utils/animated_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final appKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseAppExtensions.ensureInitialized();
  FirebaseMessagingExtensions.showNotification(
      title: message.data['title'], message: message.data['message']);
}


void main() async {
  var binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: ".env");
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
              navigatorKey: appKey,
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
