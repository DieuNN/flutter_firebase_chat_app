import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/ui/widget/contact_page/contact_list.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: const ContactList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/add_contact");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
