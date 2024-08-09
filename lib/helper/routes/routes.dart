import 'package:appariteur/views/document/documentbody.dart';
import 'package:appariteur/views/fiche%20paie/fichevue.dart';
import 'package:appariteur/views/widgets/addonglobal/bottombar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

import '../../controllers/loginController/childlogin.dart';
import '../../data/apihelper.dart';
import '../../views/contrat/contrabody.dart';
import '../../views/disponibilite/dispovue.dart';
import '../../views/profil/profilevue.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  String token = '';
  Future<String> retrieveToken() async {
    final user = await AuthApi.getLocalUserData();
    if (user != null) {
      token = user.token!;

    } else {
      token = '';
    }
    return token;
  }
  RouteSettings? redirect(String? route) {

    final token = retrieveToken();
    if (token == null) {

      return RouteSettings(name: RouteHelper.getSignInRoute(''));
    }
    return null; // Pas de redirection si le token existe
  }
}
class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String profile = '/profile';
  static const String fichesPaie = '/fichesPaie';
  static const String contrat = '/contrat';
  static const String document = '/document';

  static String getInitialRoute() => '$initial';
  static String getSplashRoute() => '$splash';
  static String getOnBoardingRoute() => '$onBoarding';
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute() => '$signUp';
  static String getProfileRoute() => '$profile';
  static String getFichesPaieRoute() => '$fichesPaie';
  static String getContratRoute() => '$contrat';
  static String getDocumentRoute() => '$document';
  static List<GetPage> routes = [

    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: initial, page: () => MyBottomNav()),
    GetPage(name: profile, page: () => ProfileVue()),
    GetPage(name: fichesPaie, page: () => FicheVue()),
    GetPage(name: contrat, page: () => ContratVue()),
    GetPage(name: document, page: () => DocumentShild()),

  ];
}