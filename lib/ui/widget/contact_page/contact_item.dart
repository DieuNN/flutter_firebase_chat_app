import 'dart:developer';

import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/user.dart';
import 'package:chat_app/ui/widget/chat_page/conversation_item.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({Key? key, required this.contact, this.trailingButton})
      : super(key: key);
  final User contact;
  final Widget? trailingButton;

  @override
  Widget build(BuildContext context) {
    final signedInUser = auth.FirebaseAuth.instance.currentUser!;
    return ListTile(
      onTap: () {
        final conversation = Conversation(
          fromUid: signedInUser.uid,
          toEmail: contact.email,
          fromEmail: signedInUser.email,
          toAvatar: contact.photoUrl,
          fromAvatar: signedInUser.photoURL,
          lastMessageTime: null,
          lastMessage: null,
          toName: contact.displayName,
          fromName: signedInUser.displayName,
          toUid: contact.uid,
        ).toMap();
        Navigator.of(context).pushNamed("/chat", arguments: {conversation});
      },
      leading: UserCircleAvatar(imageUrl: contact.photoUrl),
      title: Text(
        contact.displayName,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        contact.email,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: trailingButton,
    );
  }
}
