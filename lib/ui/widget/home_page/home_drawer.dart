import 'package:chat_app/blocs/pages/page_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/network/firebase_authentication.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeDrawer extends StatelessWidget {
  HomeDrawer({Key? key}) : super(key: key);

  final List<DrawerItem> drawerItemList = [
    DrawerItem(
      icon: const Icon(
        Icons.chat,
        color: Colors.white,
      ),
      title: "Chat",
    ),
    DrawerItem(
      icon: const Icon(
        Icons.contacts,
        color: Colors.white,
      ),
      title: "Contacts",
    ),
    DrawerItem(
      icon: const Icon(
        Icons.call,
        color: Colors.white,
      ),
      title: "Call",
    ),
    DrawerItem(
      icon: const Icon(
        Icons.person,
        color: Colors.white,
      ),
      title: "Account",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppConstants.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const UserCircleAvatar(),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.displayName
                              ?.trim()
                              .isEmpty ?? "".isEmpty
                          ? FirebaseAuth.instance.currentUser!.uid
                          : FirebaseAuth.instance.currentUser!.displayName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildDrawerItemList(context),
              ],
            ),
            _buildSignOutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        "Logout",
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        FirebaseAuthentication.signOut();
        Fluttertoast.showToast(msg: "Sign out successful");
        Navigator.popAndPushNamed(context, "/login");
      },
    );
  }

  Widget _buildDrawerItemList(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: ListView.builder(
        itemCount: drawerItemList.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildDrawerItem(
            drawerItem: drawerItemList[index],
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({required DrawerItem drawerItem, int index = 0}) {
    return BlocConsumer<PageBloc, PageState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onTap: () {
            context.read<PageBloc>().add(ChangePageEvent(screenIndex: index));
            Navigator.of(context).pop();
          },
          tileColor: index == (state as PageCurrentState).currentPageIndex
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          leading: drawerItem.icon,
          title: Text(
            drawerItem.title,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

class DrawerItem {
  final Icon icon;
  final String title;

  DrawerItem({required this.icon, required this.title});
}
