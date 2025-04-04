import 'package:appariteur/controllers/carteController/carteController.dart';
import 'package:flutter/material.dart';
import '../../controllers/fichepaieController/fichePaieChild.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';

class CarteVue extends StatelessWidget {
  static String routeName = "/fiche";

  const CarteVue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarS(
        showBackButton: false,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Carte Professionnelle", // Pass the page name here
      ),
      backgroundColor: Color(0xFFffffff),
      body: CarteController(),
    );
  }
}
