import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/apihelper.dart';
import '../../helper/permission/permission.dart';


class ProfileImgEditing extends StatefulWidget {
  const ProfileImgEditing({
    super.key,
  });

  @override
  ProfileImgEditingState createState() => ProfileImgEditingState();
}

class ProfileImgEditingState extends State<ProfileImgEditing> {
  String imagePath = "";
  final PermissionService _permissionService = PermissionService();

  Future<void> _pickImage() async {
    ImagePicker picker = ImagePicker();
    var imagePike = await picker.pickImage(source: ImageSource.gallery);
    imagePath = imagePike!.path;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userData = AuthApi.getLocalUserData();
    if (userData != null) {
      return SizedBox(
        height: 120,
        width: 120,
        child: Stack(
          alignment: Alignment.center, // Aligner le contenu au centre du Stack
          children: [
            (imagePath == "")
                ? CircleAvatar(
              radius:
              60,
              backgroundColor: Colors.transparent,
              backgroundImage: (imagePath == "")
                  ? Image.network(
                "https://appariteur.com/admins/user_images/${userData}",
                fit: BoxFit
                    .contain,
              ).image
                  : null,
            )
                : CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Image.file(
                  File(imagePath),
                  width: 115,
                  height: 115,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              right: 100,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: Colors.blueGrey),
                    ),
                    backgroundColor: const Color(0xFFF5F6F9),
                  ),
                  onPressed: _pickImage,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            )
          ],
        ),
      );
    }
    // Ajout de ce return pour s'assurer que chaque chemin de code renvoie un Widget
    return Container();
  }
}