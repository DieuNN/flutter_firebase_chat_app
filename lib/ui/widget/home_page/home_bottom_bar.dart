import 'package:chat_app/blocs/pages/page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PageBloc, PageState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.black),
          child: BottomNavigationBar(
            unselectedIconTheme: IconThemeData(color: Colors.grey.shade700),
            backgroundColor: Colors.red,
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedItemColor: Colors.red,
            onTap: (value) {
              context.read<PageBloc>().add(ChangePageEvent(screenIndex: value));
            },
            currentIndex: (state as PageCurrentState).currentPageIndex,
            items: [
              _buildBottomBarItem(
                icon: const Icon(
                  Icons.chat,
                ),
                label: "Chat",
              ),
              _buildBottomBarItem(
                icon: const Icon(
                  Icons.contacts,
                ),
                label: "Contacts",
              ),
              _buildBottomBarItem(
                icon: const Icon(
                  Icons.call,
                ),
                label: "Call",
              ),
              _buildBottomBarItem(
                icon: const Icon(
                  Icons.person,
                ),
                label: "Account",
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildBottomBarItem(
      {required Icon icon, required String label}) {
    return BottomNavigationBarItem(
      icon: icon,
      label: label,
    );
  }
}
