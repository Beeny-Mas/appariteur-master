import 'package:flutter/material.dart';
import '../../controllers/profile/child.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';

class ProfileVue extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileVue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarS(
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Profil", // Pass the page name here
      ),
      backgroundColor: Colors.blueAccent,
      body: ProfileChild(),
    );
  }
}
