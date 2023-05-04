import 'dart:developer';
import 'dart:io';

import 'package:chat_app/firebase_extensions/firebase_storage.dart';
import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:chat_app/model/enum/message_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/entity/user.dart' as model;

extension FirebaseFirestoreExtensions on FirebaseFirestore {
  static final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users");
  static final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection("conversations");

  static Future<void> updateUserProfile(
      {required String name,
      required String email,
      String? profilePicture,
      required String uid}) async {
    final updateValue = profilePicture == null
        ? {"name": name, "email": email}
        : {"name": name, "email": email, "photoUrl": profilePicture};
    return await _userCollection.doc(uid).update({
      "photoUrl": profilePicture,
    });
  }

  static Future<void> initUserData(
      {required String uid,
      required String email,
      required String name,
      String? photoUrl}) async {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
    return await _userCollection.doc(uid).set(model.User(
          uid: uid,
          creationTime: DateTime.now().toIso8601String(),
          email: email,
          contacts: [],
          fcmToken: "",
          photoUrl: photoUrl,
          displayName: name,
          groups: [],
        ).toMap());
  }

  static Future<void> updateUserFcmToken(
      {required String uid, required String newToken}) async {
    return await _userCollection.doc(uid).update({
      "fcmToken": newToken,
    });
  }

  static Future<model.User?> findContact({required String contactEmail}) async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final contactSnapshot = await _userCollection
          .where("email", isEqualTo: contactEmail)
          .where("email", isNotEqualTo: currentUserEmail)
          .get();

      if (contactSnapshot.docs.isEmpty) {
        return null;
      }

      if (contactSnapshot.docs.first.exists) {
        final model.User user = model.User.fromMap(
            contactSnapshot.docs.first.data() as Map<String, dynamic>);
        return user;
      }

      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<void> addContact({required String contactId}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (contactId == uid) {
      Fluttertoast.showToast(msg: "You cannot add yourself to your contacts");
      throw FirebaseAuthException(code: "self-adding");
    }
    await _userCollection.doc(uid).update({
      "contacts": FieldValue.arrayUnion([contactId])
    });
  }

  static Future<model.User?> getUserInfoByUid(String uid) async {
    final snapshot = await _userCollection.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return model.User.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  static Future<List<String>> _getUserContactIds(String uid) async {
    try {
      var userSnapshots = await _userCollection.doc(uid).get();
      if (userSnapshots.exists) {
        var userIds = userSnapshots.get("contacts") as List<dynamic>;
        return userIds.map((e) => e as String).toList();
      }
      return [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<List<model.User?>> getUserContacts(String uid) async {
    List<String> contactIds = await _getUserContactIds(uid);
    try {
      if (contactIds.isEmpty) {
        return [];
      }

      List<model.User?> result = [];
      final userInfoFutures = <Future<dynamic>>[];
      for (var element in contactIds) {
        userInfoFutures.add(getUserInfoByUid(element));
      }

      final userInfoList = await Future.wait(userInfoFutures);
      userInfoList.where((element) {
        return element != null;
      }).forEach((element) {
        result.add(element);
      });
      return result;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<DocumentReference> _createConversation(
      Conversation conversation) async {
    final conversationRef =
        await _conversationsCollection.add(conversation.toMap());
    await _subscribeToConversation(conversation, conversationRef.id);
    return conversationRef;
  }

  Future<Conversation?> getConversation(String toUid) async {
    final String fromUid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await _conversationsCollection
        .where("fromUid", isEqualTo: fromUid)
        .where("toUid", isEqualTo: toUid)
        .get();
    final snapshotReverse = await _conversationsCollection
        .where("fromUid", isEqualTo: toUid)
        .where("toUid", isEqualTo: fromUid)
        .get();
    final fromUser = await getUserInfoByUid(fromUid);
    final toUser = await getUserInfoByUid(toUid);
    if (fromUser == null || toUser == null) {
      return null;
    }
    if (snapshot.size == 0 && snapshotReverse.size == 0) {
      final conversation = Conversation(
        fromUid: fromUser.uid,
        toUid: toUser.uid,
        fromName: fromUser.displayName,
        toName: toUser.displayName,
        lastMessage: null,
        lastMessageTime: null,
        fromAvatar: fromUser.photoUrl,
        toAvatar: toUser.photoUrl,
        fromEmail: fromUser.email,
        toEmail: toUser.email,
      );
      await _createConversation(conversation);
      return conversation;
    }
    if (snapshot.size > 0) {
      return Conversation.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>);
    } else {
      return Conversation.fromJson(
          snapshotReverse.docs.first.data() as Map<String, dynamic>);
    }
  }

  static Future<List<String>?> getUserSubscribedGroupIds(String? uid) async {
    if (uid == null) {
      return [];
    }
    final userSnapshots = await _userCollection.doc(uid).get();
    final groupIds = await userSnapshots.get("groups") as List<dynamic>;
    return groupIds.map((e) => e.toString()).toList();
  }

  static Future<Conversation?> _getConversationInfo(
      String? conversationId) async {
    if (conversationId == null) {
      return null;
    }
    try {
      final conversationSnapshot =
          await _conversationsCollection.doc(conversationId).get();
      return Conversation.fromJson(
          conversationSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Conversation>> getConversations(
      {required String uid}) async {
    final result = <Conversation>[];

    List<String>? userSubscribedGroupIds = await getUserSubscribedGroupIds(uid);
    if (userSubscribedGroupIds == null || userSubscribedGroupIds.isEmpty) {
      return [];
    }

    try {
      final conversationFutures = <Future<dynamic>>[];
      for (var value in userSubscribedGroupIds) {
        conversationFutures.add(_getConversationInfo(value));
      }

      var conversations = await Future.wait(conversationFutures);

      conversations.where((element) => element != null).forEach((e) {
        result.add(e);
      });

      result.sort(
        (first, second) {
          int result = (first.lastMessageTime
                  ?.compareTo(second.lastMessageTime ?? Timestamp.now())) ??
              0;
          return -result;
        },
      );
      return result;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<String?> _getConversationUid(Conversation conversation) async {
    final snapshots = await _conversationsCollection
        .where("fromUid", isEqualTo: conversation.fromUid)
        .where("toUid", isEqualTo: conversation.toUid)
        .get();

    final snapshotsReversed = await _conversationsCollection
        .where("fromUid", isEqualTo: conversation.toUid)
        .where("toUid", isEqualTo: conversation.fromUid)
        .get();

    if (snapshots.size > 0) {
      return snapshots.docs.first.id;
    }

    if (snapshotsReversed.size > 0) {
      return snapshotsReversed.docs.first.id;
    }

    return null;
  }

  static Future<void> sendMessage(
      {required MessageContent messageContent,
      required Conversation conversation}) async {
    try {
      var conversationUid = await _getConversationUid(conversation);

      conversationUid ??= (await _createConversation(conversation)).id;

      MessageType messageType =
          messageContent.type == "text" ? MessageType.text : MessageType.image;

      switch (messageType) {
        case MessageType.text:
          _sendTextMessage(
              conversationUid: conversationUid, content: messageContent);
          break;
        case MessageType.image:
          _sendImageMessage(
              content: messageContent, conversationUid: conversationUid);
          break;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  static Future<void> _updateConversationLastMessage(
      String ref, String latestMessage) async {
    await _conversationsCollection.doc(ref).update({
      "lastMessage": latestMessage,
      "lastMessageTime": Timestamp.now(),
    });
  }

  static Future<List<MessageContent>> getMessages(
      Conversation conversation) async {
    final result = <MessageContent>[];

    try {
      final conversationUid = await _getConversationUid(conversation);

      final messagesSnapshot = await _conversationsCollection
          .doc(conversationUid)
          .collection("messages")
          .orderBy("timeStamp", descending: true)
          .get();
      for (var element in messagesSnapshot.docs) {
        result.add(MessageContent.fromJson(element.data()));
      }
      return result;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<void> _sendTextMessage({
    required String conversationUid,
    required MessageContent content,
  }) async {
    final messagesCollection =
        _conversationsCollection.doc(conversationUid).collection("messages");
    await messagesCollection.add(content.toMap());
    await _updateConversationLastMessage(conversationUid, content.content!);
  }

  static Future<void> _sendImageMessage({
    required MessageContent content,
    required String conversationUid,
  }) async {
    if (content.file == null) {
      return;
    }
    final downloadUrl =
        await FirebaseStorageExtensions.uploadImage(content.file!);
    final messagesCollection =
        _conversationsCollection.doc(conversationUid).collection("messages");
    content.content = downloadUrl;
    content.type = "image";
    await messagesCollection.add(content.toMap());
    await _updateConversationLastMessage(conversationUid, content.content!);
  }

  static Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>
      getMessagesSnapshots(Conversation conversation) async {
    String? conversationUid = await _getConversationUid(conversation);

    if (conversationUid == null) {
      return null;
    }

    return _conversationsCollection
        .doc(conversationUid)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  static Future<void> _subscribeToConversation(
      Conversation conversation, String conversationUid) async {
    await _userCollection.doc(conversation.fromUid).update({
      "groups": FieldValue.arrayUnion([conversationUid])
    });
    await _userCollection.doc(conversation.toUid).update({
      "groups": FieldValue.arrayUnion([conversationUid])
    });
  }
}
