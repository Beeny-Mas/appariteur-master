import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/apihelper.dart';
import '../../models/user.dart';

class ProfileImg extends StatelessWidget {
  const ProfileImg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: AuthApi.getLocalUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data != null) {
          UserData userData = snapshot.data!;
          print('UserData: ${userData.toJson()}');

          return CircleAvatar(
            radius: 65,
            backgroundImage: NetworkImage(
              "https://appariteur.com/appa/admins/user_images/${userData.image}",
            ),
          );
        } else {
          return const CircleAvatar(
            backgroundImage: AssetImage("assets/images/logo.png"),
          );
        }
      },
    );
  }
}
