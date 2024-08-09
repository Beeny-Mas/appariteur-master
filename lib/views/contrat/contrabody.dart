import 'package:flutter/material.dart';
import '../../controllers/contratController/contratChild.dart';
import '../notif/notifScreen.dart';
import '../widgets/addonglobal/topbar.dart';

class ContratVue extends StatelessWidget {
  static String routeName = "/home";
  const ContratVue({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: TopBarS(
        showBackButton: true,
        onNotificationPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NotifScreen()));
        },
        PageName: "Contrats",
      ),
      backgroundColor: Colors.grey,
      body: ContratChild(),
      //bottomNavigationBar: MyBottomBar(),
    );
  }
}
