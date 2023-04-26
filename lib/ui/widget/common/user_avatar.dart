import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCircleAvatar extends StatelessWidget {
  const UserCircleAvatar(
      {super.key,
      this.imageUrl,
      this.width = 48,
      this.height = 48,
      this.imageFile});

  final String? imageUrl;
  final double height;
  final double width;
  final File? imageFile;

  ImageProvider _getImageProvider() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    }
    return const AssetImage("assets/images/user.png");
  }

  DecorationImage _getImage() {
    ImageProvider image = _getImageProvider();
    return DecorationImage(image: image, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: _getImage(),
        color: Colors.white
      ),
    );
  }
}
