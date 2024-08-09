import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBarS extends StatelessWidget implements PreferredSizeWidget {
  final int _notificationCount = 0;
  final VoidCallback onNotificationPressed;
  final String PageName;
  final TabController? tabController;
  final bool showBackButton;

  TopBarS({
    super.key,
    required this.onNotificationPressed,
    required this.PageName,
    this.tabController,
    this.showBackButton = false,
  });

  int get notificationCount => _notificationCount;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
      child: AppBar(
        backgroundColor: Colors.blue,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
        ),
        title: Text(
          PageName,
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Désactive le bouton de retour par défaut
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
            : null,
        actions: <Widget>[
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: onNotificationPressed,
              ),
              if (_notificationCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: tabController != null
            ? TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'Missions effectuées'),
            Tab(text: 'Missions à venir'),
          ],
        )
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}
