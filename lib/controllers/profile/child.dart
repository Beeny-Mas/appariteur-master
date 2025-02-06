import 'package:appariteur/controllers/loginController/childlogin.dart';
import 'package:appariteur/controllers/profile/profileimg.dart';
import 'package:appariteur/controllers/profile/profilpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/apihelper.dart';
import '../../views/contrat/contrabody.dart';
import '../../views/document/documentbody.dart';
import '../../views/fiche paie/fichevue.dart';
import 'firscontaint.dart';

class ProfileChild extends StatelessWidget {
  const ProfileChild({Key? key});

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(vertical: _w / 40),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: const ProfileImg(),
          ),
           SizedBox(height: _w /20),
          FirsContentPro(
            text: "Mon Compte",
            icon: "assets/icons/User Icon.svg",
            press: () => {
              Navigator.push(context, SlideTransition1(const ProfilePage())),
            },
          ),
        /*  FirsContentPro(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(NotifScreen()),
              ),
            },
          ),*/
          FirsContentPro(
            text: "Contrats",
            icon: "assets/icons/task.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(ContratVue()),
              ),
            },
          ),
          FirsContentPro(
            text: "Fiches de Paie",
            icon: "assets/icons/task.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(FicheVue()),
              ),
            },
          ),
          FirsContentPro(
            text: "Documents",
            icon: "assets/icons/doc.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(const DocumentShild()),
              ),
            },
          ),
         /* FirsContentPro(
            text: "Paramètres",
            icon: "assets/icons/Settings.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(Parrametre()),
              ),
            },
          ),
          FirsContentPro(
            text: "Aide",
            icon: "assets/icons/Question mark.svg",
            press: () => {
              Navigator.push(
                context,
                SlideTransition1(AideBody()),
              ),
            },
          ),*/
          FirsContentPro(
            text: "Déconnexion",
            icon: "assets/icons/Log out.svg",
            press: () async {
              await AuthApi.logout();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  SignInScreen()),
              );
            },
          ),

        ],
      ),
    );
  }
}

class SlideTransition1 extends PageRouteBuilder {
  final Widget page;
  SlideTransition1(this.page)
      : super(
    pageBuilder: (context, animation, anotherAnimation) => page,
    transitionDuration: const Duration(milliseconds: 1000),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, anotherAnimation, child) {
      animation = CurvedAnimation(
        curve: Curves.fastLinearToSlowEaseIn,
        parent: animation,
        reverseCurve: Curves.fastOutSlowIn,
      );
      return SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),
        child: page,
      );
    },
  );
}
