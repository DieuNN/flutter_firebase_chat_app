import 'dart:async';

import 'package:chat_app/blocs/contact/contact_bloc.dart';
import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/model/entity/user.dart';
import 'package:chat_app/ui/widget/chat_page/user_search_field.dart';
import 'package:chat_app/ui/widget/contact_page/contact_item.dart';
import 'package:chat_app/ui/widget/contact_page/no_contact_to_add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({Key? key, this.arguments}) : super(key: key);
  final Object? arguments;

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  late final TextEditingController searchEditController;
  List<User> contacts = <User>[];
  Timer? debounce;

  @override
  void initState() {
    searchEditController = TextEditingController(
        text: widget.arguments == null
            ? ""
            : (widget.arguments as Map<String, dynamic>)["text"]);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.arguments != null) {
      context
          .read<ContactBloc>()
          .add(SearchContactEvent(keyword: searchEditController.text));
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add a contact",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactSearchSuccessState) {
            setState(() {
              if (state.user != null) {
                contacts = [state.user!];
              }
            });
          }

          if (state is AddContactSuccessState) {
            Fluttertoast.showToast(msg: "Contact added");
            Navigator.pop(context);
          }
        },
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildSearchBar(),
              _buildContactResult(context),
            ],
          ),
        ),
      ),
    );
  }

  _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: UserSearchField(
        searchEditingController: searchEditController,
        onChange: (value) {
          contacts = [];
          if (debounce?.isActive ?? false) {
            debounce?.cancel();
          }
          debounce = Timer(
            const Duration(seconds: 1),
            () {
              context.read<ContactBloc>().add(
                    SearchContactEvent(keyword: value),
                  );
            },
          );
        },
        onSuffixClick: () {
          context
              .read<ContactBloc>()
              .add(SearchContactEvent(keyword: searchEditController.text));
        },
      ),
    );
  }

  _buildContactResult(BuildContext context) {
    final items = contacts
        .map(
          (contact) => ContactItem(
            contact: contact,
            trailingButton: IconButton(
              onPressed: () {
                context
                    .read<ContactBloc>()
                    .add(AddContactEvent(contactId: contact.uid));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        )
        .toList();
    return contacts.isEmpty
        ? const Center(
            child: NoContactToAdd(),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return items[index];
            },
            itemCount: contacts.length,
          );
  }
}
