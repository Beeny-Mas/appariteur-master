import 'package:appariteur/views/carte/cartevue.dart';
import 'package:appariteur/views/mission/missionvue.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../disponibilite/dispovue.dart';
import '../../planning/planingvue.dart';
import '../../profil/profilevue.dart';


class MyBottomNav extends StatefulWidget {
  const MyBottomNav({super.key});

  @override
  State<MyBottomNav> createState() => MyBottomNavState();
}

class MyBottomNavState extends State<MyBottomNav> {
  int _currentIndex =
  0; // Défini sur 0 pour afficher la page d'accueil par défaut.
  Color? _backgroundColor;
  @override
  void initState() {
    super.initState();
    // Initialiser la couleur de fond en fonction de la première page.
    _backgroundColor = Colors.grey[200];
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      Icon(Icons.calendar_month, size: 30, color: Colors.blueGrey),
      Icon(Icons.add_business, size: 30, color: Colors.blueGrey),
      Icon(Icons.table_rows_sharp, size: 30, color: Colors.blueGrey),
      Icon(Icons.credit_card, size: 30, color: Colors.blueGrey),


      Icon(Icons.person, size: 30, color: Colors.blueGrey)
    ];
    return Scaffold(
      backgroundColor:
      _backgroundColor, // Utiliser la couleur de fond dynamique
      body: getSelectedWidget(index: _currentIndex),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.white60,
        items: items,
        index: _currentIndex,
        onTap: (selected) {
          setState(() {
            _currentIndex = selected;
            // Mettre à jour la couleur de fond en fonction de la page sélectionnée.
            _updateBackgroundColor();
          });
        },
        height: 70,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _updateBackgroundColor() {
    switch (_currentIndex) {
      case 0:
        _backgroundColor = Colors.grey[200];
        break;
      case 1:
        _backgroundColor = Colors.grey[200];
        break;
      case 2:
        _backgroundColor = Colors.grey[200];
        break;
      case 3:
        _backgroundColor = Colors.blue;
        break;
      default:
        _backgroundColor = Colors.grey[200];
        break;
    }
  }

  Widget getSelectedWidget({required int index}) {
    switch (index) {
      case 1:
        return DispoScreen();
      case 2:
        return const MissionScreen();
      case 3:
        return const CarteVue();

      case 4 :
        return const ProfileVue();
      default:
        return PlanningScreen();
    }
  }
}
