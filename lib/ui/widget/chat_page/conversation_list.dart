import 'dart:developer';

import 'package:chat_app/blocs/conversation/conversation_bloc.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/ui/widget/chat_page/conversation_item.dart';
import 'package:chat_app/ui/widget/chat_page/no_conversation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationList extends StatefulWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  List<Conversation> conversations = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ConversationBloc>().add(ConversationsLoadEvent(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> conversationWidgets =
        conversations.map((e) => ConversationItem(conversation: e)).toList();
    return BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
      if (state is ConversationsLoadSuccessState) {
        setState(() {
          conversations = state.conversations;
        });
      }
    }, builder: (context, state) {
          log("Conversation list state is ${state.runtimeType}");
      if (state is ConversationsLoadSuccessState) {
        return conversations.isEmpty
            ? const NoConversationWidget()
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (BuildContext context, int index) {
                  return conversationWidgets[index];
                },
                itemCount: conversationWidgets.length,
              );
      }
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          backgroundColor: Colors.black,
        ),
      );
    });
  }
}
