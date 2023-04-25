import 'dart:developer';

import 'package:chat_app/blocs/contact/contact_bloc.dart';
import 'package:chat_app/model/entity/user.dart';
import 'package:chat_app/ui/widget/chat_page/no_conversation_widget.dart';
import 'package:chat_app/ui/widget/contact_page/contact_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<User?> contacts = [];

  @override
  void didChangeDependencies() {
    context.read<ContactBloc>().add(LoadContactsEvent());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final items = contacts
        .where((contact) => contact != null)
        .map((contact) => ContactItem(contact: contact!))
        .toList();
    return BlocConsumer<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is LoadContactsSuccessState) {
          setState(() {
            contacts = state.contacts;
          });
        }
      },
      builder: (context, state) {
        if (state is LoadContactsInProgressState) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              color: Colors.white,
            ),
          );
        }
        return contacts.isEmpty
            ? const NoConversationWidget()
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return items[index];
                },
                itemCount: contacts.length,
              );
      },
    );
  }
}
