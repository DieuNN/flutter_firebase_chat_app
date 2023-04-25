import 'package:cloud_firestore/cloud_firestore.dart';

class MessageContent {
  String? senderUid;
  final String? content;
  final String? type;
  final Timestamp? timeStamp;

  MessageContent({this.senderUid, this.content, this.type, this.timeStamp});

  factory MessageContent.fromJson(Map<String, dynamic> messageContent) {
    return MessageContent(
        senderUid: messageContent["senderUid"],
        content: messageContent["content"],
        type: messageContent["type"],
        timeStamp: messageContent["timeStamp"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "senderUid": senderUid,
      "content": content,
      "type": type,
      "timeStamp": timeStamp,
    };
  }
}
