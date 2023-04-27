import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as f_storage;

class FirebaseStorage {
  Future<String?> uploadAvatar(File file, String uid) async {
    f_storage.FirebaseStorage storage = f_storage.FirebaseStorage.instance;
    final fileName = "${uid}_${DateTime.now().toIso8601String()}";
    final result = await storage
        .ref("uploads")
        .child("avatars/")
        .child(fileName)
        .putFile(file);
    return await result.ref.getDownloadURL();
  }

  Future<String?> uploadImage(File file) async {
    f_storage.FirebaseStorage storage = f_storage.FirebaseStorage.instance;
    final fileName =
        "${file.uri.pathSegments.first}_${DateTime.now().toIso8601String()}";
    final result = await storage
        .ref("uploads")
        .child("images/")
        .child(fileName)
        .putFile(file);
    return await result.ref.getDownloadURL();
  }
}
