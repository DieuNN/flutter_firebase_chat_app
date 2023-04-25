import 'dart:developer';

import 'package:chat_app/blocs/authentication/authentication_bloc.dart';
import 'package:chat_app/blocs/pages/page_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/page/account_page.dart';
import 'package:chat_app/ui/page/call_page.dart';
import 'package:chat_app/ui/page/chat_page.dart';
import 'package:chat_app/ui/page/contact_page.dart';
import 'package:chat_app/ui/widget/home_page/home_app_bar.dart';
import 'package:chat_app/ui/widget/home_page/home_bottom_bar.dart';
import 'package:chat_app/ui/widget/home_page/home_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        var dialog = ProgressDialog(context: context);
        if (state is SignOutInProgressState) {
          dialog.show(msg: "Signing out ...");
        }
        if (state is SignOutSuccessState) {
          dialog.close();
          Navigator.of(context)
              .pushNamedAndRemoveUntil("/login", (route) => false);
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          body: BlocBuilder<PageBloc, PageState>(
            builder: (context, state) {
              switch ((state as PageCurrentState).currentPageIndex) {
                case 0:
                  return const ChatPage();
                case 2:
                  return const CallPage();
                case 1:
                  return const ContactPage();
                case 3:
                  return const AccountPage();
              }
              return const Placeholder();
            },
          ),
          backgroundColor: AppConstants.primaryColor,
          drawer: HomeDrawer(),
          bottomNavigationBar: const HomeBottomBar(),
          appBar: HomeAppBar(
            scaffoldKey: scaffoldKey,
          ),
        ),
      ),
    );
  }
}
