import 'package:flutter/material.dart';
import '../../controllers/planingcontroler/child.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';

class PlanningScreen extends StatelessWidget {
  static String routeName = "/planning";

  PlanningScreen({Key? key}) : super(key: key);
  // Replace with your actual notification count

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarS(
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Accueil", // Pass the page name here
      ),
      backgroundColor: Colors.white,
      body:  CalendarPage (),
    );
  }
}
