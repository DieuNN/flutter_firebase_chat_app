import 'dart:developer';

import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/ui/widget/common/user_avatar.dart';
import 'package:chat_app/utils/keyboard_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  final Conversation conversation;

  const ConversationItem({super.key, required this.conversation});

  String _getMessageTime(Timestamp time) {
    final now = Timestamp.now().millisecondsSinceEpoch;
    final diff = now - time.millisecondsSinceEpoch;
    if (Duration(milliseconds: diff).inSeconds < 10) {
      return "Just now";
    }
    if (Duration(milliseconds: diff).inSeconds < Duration.secondsPerMinute) {
      return "${(diff / 1000).round()}s ago";
    }
    if (Duration(milliseconds: diff).inMinutes < Duration.minutesPerHour) {
      return "${Duration(milliseconds: diff).inMinutes}m ago";
    }

    if (Duration(milliseconds: diff).inHours < Duration.hoursPerDay) {
      return "${Duration(milliseconds: diff).inHours}h ago";
    }
    return "${Duration(milliseconds: diff).inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    String conversationName;
    String? conversationImage;
    String currentUid = FirebaseAuth.instance.currentUser!.uid;

    // Reverse sender and receiver
    if (currentUid == conversation.fromUid) {
      conversationName = conversation.toName!;
      conversationImage = conversation.toAvatar;
    } else {
      conversationName = conversation.fromName!;
      conversationImage = conversation.fromAvatar;
    }

    return ListTile(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/chat", arguments: {conversation.toMap()});
        KeyboardUtil.hideKeyboard();
      },
      splashColor: Colors.transparent,
      leading: UserCircleAvatar(imageUrl: conversationImage),
      title: Text(
        conversationName ?? "",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: conversation.lastMessage != null
          ? Text(
              maxLines: 1,
              conversation.lastMessage!.contains("alt=media")
                  ? "Has sent a media file"
                  : conversation.lastMessage!,
              style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            )
          : null,
      trailing: Text(
        conversation.lastMessageTime == null
            ? ""
            : _getMessageTime(conversation.lastMessageTime!),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
