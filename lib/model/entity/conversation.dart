import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String? fromUid;
  final String? fromName;
  final String? fromEmail;
  final String? toUid;
  final String? toName;
  final String? fromAvatar;
  final String? toAvatar;
  final String? toEmail;
  final String? lastMessage;
  final Timestamp? lastMessageTime;

  Conversation(
      {this.fromEmail,
      this.toEmail,
      this.fromUid,
      this.fromName,
      this.toUid,
      this.toName,
      this.fromAvatar,
      this.toAvatar,
      this.lastMessage,
      this.lastMessageTime});

  Map<String, dynamic> toMap() {
    return {
      "fromUid": fromUid,
      "fromName": fromName,
      "fromEmail": fromEmail,
      "toUid": toUid,
      "toName": toName,
      "fromAvatar": fromAvatar,
      "toAvatar": toAvatar,
      "toEmail": toEmail,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> message) {
    return Conversation(
      fromUid: message["fromUid"],
      fromName: message["fromName"],
      fromEmail: message["fromEmail"],
      toUid: message["toUid"],
      toName: message["toName"],
      fromAvatar: message["fromAvatar"],
      toAvatar: message["toAvatar"],
      toEmail: message["toEmail"],
      lastMessage: message["lastMessage"],
      lastMessageTime: message["lastMessageTime"],
    );
  }
}
