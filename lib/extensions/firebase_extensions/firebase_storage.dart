import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

extension FirebaseStorageExtensions on FirebaseStorage {
  static Future<String?> uploadAvatar(File file, String uid) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileName = "${uid}_${DateTime.now().toIso8601String()}";
    final result = await storage
        .ref("uploads")
        .child("avatars/")
        .child(fileName)
        .putFile(file);
    return await result.ref.getDownloadURL();
  }

  static Future<String?> uploadImage(File file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileName =
        "${file.uri.pathSegments.first}_${DateTime.now().toIso8601String()}";
    final result =
        storage.ref("uploads").child("images/").child(fileName).putFile(file);
    result.snapshotEvents.listen((event) {
      log("Sending file, ${(event.bytesTransferred / event.totalBytes) * 100}%");

      if (event.state == TaskState.running) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: "Sending image");
      }

      if (event.state == TaskState.success) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: "Image sent!");
      }

      if (event.state == TaskState.error) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: "Image error!");
      }
    });
    return await (await result).ref.getDownloadURL();
  }
}
