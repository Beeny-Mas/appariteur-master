import 'package:flutter/material.dart';
import '../../controllers/fichepaieController/fichePaieChild.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';

class FicheVue extends StatelessWidget {
  static String routeName = "/fiche";

  const FicheVue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarS(
        showBackButton: true,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Fiches de Paie", // Pass the page name here
      ),
      backgroundColor: Colors.blueAccent,
      body: FichesPaieChild(),
    );
  }
}
