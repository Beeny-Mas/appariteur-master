import 'package:appariteur/controllers/missioncontroller/childmission.dart';
import 'package:flutter/material.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';


class MissionScreen extends StatelessWidget {
  static String routeName = "/mission";
  const MissionScreen({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TopBarS(
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Missions Effectuées", // Pass the page name here
      ),
      backgroundColor: Colors.white,
      body: BodyM(),
      //bottomNavigationBar: MyBottomBar(),
    );
  }
}
