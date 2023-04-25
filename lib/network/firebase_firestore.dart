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
      {String? name,
      required String email,
      String? profilePicture,
      required String uid}) async {
    return await _userCollection.doc(uid).update(User(
          email: email,
          creationTime: DateTime.now().toIso8601String(),
          uid: uid,
          displayName: name,
          photoUrl: profilePicture,
          fcmToken: "",
        ).toMap());
  }

  Future<void> initUserData(
      {required String uid,
      required String email,
      String? name,
      String? photoUrl}) async {
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

  Future<List<User>> findContact({required String contactEmail}) async {
    try {
      final result = <User>[];
      final currentUserEmail = auth.FirebaseAuth.instance.currentUser!.email!;
      final values =
          await _userCollection.where("email", isEqualTo: contactEmail).get();
      for (var element in values.docs) {
        result.add(User.fromMap(element.data() as Map<String, dynamic>));
      }
      return result;
    } catch (e) {
      log(e.toString());
      return [];
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

  Future<User?> getUserInfoByUid(String uid) async {
    final snapshot = await _userCollection.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return User.fromMap(snapshot.data() as Map<String, dynamic>);
  }

  // Future<List<User>> loadUserContacts(String uid) async {
  Future<List<User>> getUserContacts(String uid) async {
    try {
      List<User> result = <User>[];
      var userDocs = (await _userCollection.doc(uid).get()).get("contacts")
          as List<dynamic>;
      List<String> contactIds = userDocs.map((e) => e.toString()).toList();
      var contacts = await _userCollection.get();
      for (var contact in contacts.docs) {
        var user = User.fromMap(contact.data() as Map<String, Object?>);
        if (contactIds.contains(user.uid)) {
          result.add(user);
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<cloud.DocumentReference> createConversation(
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

  Future<Conversation?> getConversation(String toUid) async {
    final String fromUid = auth.FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _conversationsCollection
        .where("fromUid", isEqualTo: fromUid)
        .where("toUid", isEqualTo: toUid)
        .get();
    final fromUser = await getUserInfoByUid(fromUid);
    final toUser = await getUserInfoByUid(toUid);
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
      await createConversation(conversation);
      return conversation;
    }
    return Conversation.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>);
  }

  Future<List<Conversation>> getConversations() async {
    final String uid = auth.FirebaseAuth.instance.currentUser!.uid;
    final result = <Conversation>[];
    final snapshot =
        await _conversationsCollection.where("fromUid", isEqualTo: uid).get();
    for (var element in snapshot.docs) {
      result.add(Conversation.fromJson(element.data() as Map<String, dynamic>));
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
      docId = (await createConversation(conversation)).id;
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
