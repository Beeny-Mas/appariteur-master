import 'package:flutter/material.dart';

import 'componentsNotif/bodyNotif.dart';

class NotifScreen extends StatelessWidget {
  static String routeName = "/planning";

  NotifScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0, // Supprime la boîte d'ombre de la barre d'applications
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Bords inférieurs arrondis
          ),
        ),
        title: const Center(
          child: Text(
            "Mes Notifications",
            style: TextStyle(
              color: Colors.white, // Couleur du texte
              fontSize: 24, // Taille du texte
              fontWeight: FontWeight.bold, // Style de police
            ),
          ),
        ),
      ),
      body: BodyNotif(),
      // bottomNavigationBar: MyBottomBar(selectedMenu: MenuState.planning,),
    );
  }
}
