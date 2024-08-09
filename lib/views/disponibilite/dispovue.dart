import 'package:flutter/material.dart';
import '../../controllers/disponibilite/child.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';


class DispoScreen extends StatelessWidget {
  static String routeName = "/dispo";

  DispoScreen({Key? key}) : super(key: key);
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
        PageName: "Mes Disponibilités", // Pass the page name here
      ),
      backgroundColor: Colors.white,
      body:  const DisponibiliteScreen (),
    );
  }
}
