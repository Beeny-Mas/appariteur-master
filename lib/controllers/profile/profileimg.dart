import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/apihelper.dart';
import '../../models/user.dart'; // Assurez-vous d'importer le modèle UserData

class ProfileImg extends StatelessWidget {
  const ProfileImg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData?>(
      future: AuthApi.getLocalUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher un indicateur de chargement en attendant les données
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Gérer l'erreur ici, par exemple, afficher une icône d'erreur
          return const Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data != null) {
          UserData userData = snapshot.data!;
          // Afficher les informations de l'utilisateur dans la console
          print('UserData: ${userData.toJson()}');

          return CircleAvatar(
            radius: 65,
            backgroundImage: NetworkImage(
              "https://appariteur.com/admins/user_images/${userData.image}",
            ),
          );
        } else {
          // Afficher une image par défaut si aucune donnée n'est disponible
          return const CircleAvatar(
            backgroundImage: AssetImage("assets/images/logo.png"),
          );
        }
      },
    );
  }
}
