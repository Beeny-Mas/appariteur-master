import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../widgets/addonglobal/topbar.dart';

class BodyNotif extends StatefulWidget {
  @override
  _BodyNotifState createState() => _BodyNotifState();
}

class _BodyNotifState extends State<BodyNotif> {
  final topNavBar = TopBarS(onNotificationPressed: () {}, PageName: "My Page");

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    int itemCount = topNavBar
        .notificationCount; // Use the getter method to get the notification count
    print(itemCount);
    return Scaffold(
      backgroundColor: Colors.white,
      body: itemCount == 0
          ? const Center(
              // Display message in the center of the page
              child: Text(
                "Pas de notifications pour l\'instant.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : AnimationLimiter(
              child: ListView.builder(
                itemCount: itemCount,
                padding: EdgeInsets.all(_w / 30),
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (BuildContext c, int i) {
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    delay: const Duration(milliseconds: 100),
                    child: ListItem(width: _w),
                  );
                },
              ),
            ),
    );
  }
}

class ListItem extends StatelessWidget {
  final double width;

  ListItem({required this.width});

  @override
  Widget build(BuildContext context) {
    return SlideAnimation(
      duration: const Duration(milliseconds: 2500),
      curve: Curves.fastLinearToSlowEaseIn,
      horizontalOffset: 30,
      verticalOffset: 300.0,
      child: FlipAnimation(
        duration: const Duration(milliseconds: 3000),
        curve: Curves.fastLinearToSlowEaseIn,
        flipAxis: FlipAxis.y,
        child: Container(
          margin: EdgeInsets.only(bottom: width / 20),
          height: width / 4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
