import 'dart:developer';

import 'package:chat_app/model/entity/conversation.dart';
import 'package:chat_app/model/entity/message_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fluttertoast/fluttertoast.dart';
import '../model/entity/user.dart';

class FirebaseFirestore {
  final cloud.CollectionReference _userCollection =
      cloud.FirebaseFirestore.instance.collection("users");
  final cloud.CollectionReference _conversationsCollection =
      cloud.FirebaseFirestore.instance.collection("conversations");

  Future<void> updateUserProfile(
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

  Future<void> initUserData(
      {required String uid,
      required String email,
      required String name,
      String? photoUrl}) async {
    await auth.FirebaseAuth.instance.currentUser!.updateDisplayName(name);
    return await _userCollection.doc(uid).set(User(
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

  Future<void> updateUserFcmToken(
      {required String uid, required String newToken}) async {
    return await _userCollection.doc(uid).update({
      "fcmToken": newToken,
    });
  }

  Future<User?> findContact({required String contactEmail}) async {
    try {
      final currentUserEmail = auth.FirebaseAuth.instance.currentUser!.email;

      final contactSnapshot = await _userCollection
          .where("email", isEqualTo: contactEmail)
          .where("email", isNotEqualTo: currentUserEmail)
          .get();

      if (contactSnapshot.docs.isEmpty) {
        return null;
      }

      if (contactSnapshot.docs.first.exists) {
        final User user = User.fromMap(
            contactSnapshot.docs.first.data() as Map<String, dynamic>);
        return user;
      }

      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<void> addContact({required String contactId}) async {
    final uid = auth.FirebaseAuth.instance.currentUser!.uid;
    if (contactId == uid) {
      Fluttertoast.showToast(msg: "You cannot add yourself to your contacts");
      throw auth.FirebaseAuthException(code: "self-adding");
    }
    await _userCollection.doc(uid).update({
      "contacts": cloud.FieldValue.arrayUnion([contactId])
    });
  }

  Future<User?> _getUserInfoByUid(String uid) async {
    final snapshot = await _userCollection.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return User.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  Future<List<String>> _getUserContactIds(String uid) async {
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

  Future<List<User?>> getUserContacts(String uid) async {
    List<String> contactIds = await _getUserContactIds(uid);
    try {
      if (contactIds.isEmpty) {
        return [];
      }
      List<User?> result = [];
      for (var element in contactIds) {
        final userInfo = await _getUserInfoByUid(element);
        result.add(userInfo);
      }
      return result;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<cloud.DocumentReference> _createConversation(
      Conversation conversation) async {
    final conversationRef =
        await _conversationsCollection.add(conversation.toJson());
    await subscribeToConversation(
      conversation.fromUid!,
      conversation.toUid!,
      conversationRef.id,
    );
    return conversationRef;
  }

  // TODO: Logic here should be update

  Future<Conversation?> getConversation(String toUid) async {
    final String fromUid = auth.FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _conversationsCollection
        .where("fromUid", isEqualTo: fromUid)
        .where("toUid", isEqualTo: toUid)
        .get();
    final fromUser = await _getUserInfoByUid(fromUid);
    final toUser = await _getUserInfoByUid(toUid);
    if (fromUser == null || toUser == null) {
      return null;
    }
    if (snapshot.size == 0) {
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
    return Conversation.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>);
  }

  Future<List<Conversation>> getConversations({required String uid}) async {
    final result = <Conversation>[];
    final subscribedGroupsSnapshot = (await _userCollection.doc(uid).get());

    if (subscribedGroupsSnapshot.exists) {
      final subscribedGroups =
          subscribedGroupsSnapshot.get("groups") as List<dynamic>;
      for (var element in subscribedGroups) {
        final conversation = Conversation.fromJson(
            (await _conversationsCollection.doc(element).get()).data()
                as Map<String, dynamic>);
        result.add(conversation);
      }
    }
    return result;
  }

  Future<void> sendTextMessage(
      {required MessageContent messageContent,
      required Conversation conversation}) async {
    var ref = (await _conversationsCollection
            .where("fromUid", isEqualTo: conversation.fromUid)
            .where("toUid", isEqualTo: conversation.toUid)
            .get())
        .docs;

    var docId = "";

    if (ref.isNotEmpty) {
      docId = ref.first.id;
      final messageCollection =
          _conversationsCollection.doc(docId).collection("messageContent");
      docId = ref.first.id;
      messageContent.senderUid = conversation.fromUid;
      messageCollection.add(messageContent.toJson());
      updateConversationLastMessage(docId, messageContent.content ?? "");
    } else {
      docId = (await _createConversation(conversation)).id;
      final messageCollection =
          _conversationsCollection.doc(docId).collection("messageContent");
      final newRef = await messageCollection.add(messageContent.toJson());
      updateConversationLastMessage(newRef.id, messageContent.content ?? "");
    }
  }

  Future<void> updateConversationLastMessage(
      String ref, String latestMessage) async {
    await _conversationsCollection.doc(ref).update({
      "lastMessage": latestMessage,
      "lastMessageTime": cloud.Timestamp.now(),
    });
  }

  Future<List<MessageContent>> getMessages(String toUid) async {
    final result = <MessageContent>[];
    final String fromUid = auth.FirebaseAuth.instance.currentUser!.uid;
    final ref = (await _conversationsCollection
            .where("fromUid", isEqualTo: fromUid)
            .where("toUid", isEqualTo: toUid)
            .get())
        .docs
        .first
        .id;
    final messageDocuments = await _conversationsCollection
        .doc(ref)
        .collection("messageContent")
        .orderBy("timeStamp", descending: true)
        .get();
    for (var element in messageDocuments.docs) {
      result.add(MessageContent.fromJson(element.data()));
    }
    log(result.toString());
    return result;
  }

  Future<void> sendImageMessage() async {
    final MessageContent messageContent = MessageContent();
  }

  Future<Stream<cloud.QuerySnapshot<Map<String, dynamic>>>?>
      getMessagesSnapshots(String toUid) async {
    final String fromUid = auth.FirebaseAuth.instance.currentUser!.uid;
    final ref = (await _conversationsCollection
            .where("fromUid", isEqualTo: fromUid)
            .where("toUid", isEqualTo: toUid)
            .get())
        .docs;
    if (ref.isEmpty) {
      return null;
    }
    var docId = "";
    if (ref.first.exists) {
      return _conversationsCollection
          .doc(ref.first.id)
          .collection("messageContent")
          .orderBy("timeStamp", descending: true)
          .snapshots();
    } else {}
    return null;
  }

  Future<void> subscribeToConversation(
      String fromUid, String toUid, String conversation) async {
    await _userCollection.doc(fromUid).update({
      "groups": cloud.FieldValue.arrayUnion([conversation])
    });
    await _userCollection.doc(toUid).update({
      "groups": cloud.FieldValue.arrayUnion([conversation])
    });
  }
}
