import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageContent {
  String? senderUid;
  String? content;
  String? type;
  final File? file;
  final Timestamp? timeStamp;

  MessageContent(
      {this.file, this.senderUid, this.content, this.type, this.timeStamp});

  factory MessageContent.fromJson(Map<String, dynamic> messageContent) {
    return MessageContent(
        senderUid: messageContent["senderUid"],
        content: messageContent["content"],
        type: messageContent["type"],
        timeStamp: messageContent["timeStamp"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "senderUid": senderUid,
      "content": content,
      "type": type,
      "timeStamp": timeStamp,
    };
  }
}
