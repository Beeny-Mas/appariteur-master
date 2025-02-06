import 'package:appariteur/views/splash/spash_screen.dart';
import 'package:appariteur/views/widgets/addonglobal/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/loginController/childlogin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  const AndroidInitializationSettings initializationSettingsAndroid=AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsiOs = DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(android:initializationSettingsAndroid, iOS:initializationSettingsiOs);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  String? token = prefs.getString('token');

  Widget initialScreen;
  if (!seenOnboarding) {
    initialScreen = OnboardingScreen();
  } else if (token != null && token.isNotEmpty) {
    initialScreen = MyBottomNav();
  } else {
    initialScreen = SignInScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('fr', '')],
      debugShowCheckedModeBanner: false,
      title: 'Appariteur',
      home: initialScreen,
    );
  }
}
