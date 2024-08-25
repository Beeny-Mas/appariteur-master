import 'package:appariteur/controllers/contratController/contratChild.dart';
import 'package:appariteur/controllers/profile/profilpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> takeScreenshot({
  required WidgetTester tester,
  required Widget widget,
  required String pageName,
  required bool isFinal,
  required Size sizeDp,
  required double density,
}) async {
  await tester.pumpWidgetBuilder(widget);
  await multiScreenGolden(
    tester,
    pageName,
    devices: [
      Device(
        name: isFinal ? "final" : "screen",
        size: sizeDp,
        textScale: 1,
        devicePixelRatio: density,
      ),
    ],
  );
}
Widget getScreenWrapper({
  required Widget child,
  required Locale locale,
  required bool isAndroid,

  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        platform: (isAndroid ? TargetPlatform.android : TargetPlatform.iOS),
      ),
      home: Column(
        children: [
          Container(color: Colors.black, height: 24), // Simule la barre d'état
          Expanded(child: child),
        ],
      ),
    ),
  );
}

void main() {
  testGoldens('ProfilePage Golden Test for iPad Pro and iPad Pro 2nd Gen', (WidgetTester tester) async {
    // Dimensions pour iPad Pro (12.9 pouces)
    const iPadProScreenSize = Size(1024, 1366);
    // Dimensions pour iPad Pro 2e génération
    const iPadPro2ScreenSize = Size(2048, 2732);

    // Créer le wrapper pour iPad Pro
    final widgetPro = getScreenWrapper(
      child: FichesPaieChild(),
      locale: Locale('fr'),
      isAndroid: false,
    );

    // Prendre la capture d'écran pour iPad Pro
    await takeScreenshot(
      tester: tester,
      widget: widgetPro,
      pageName: 'profile_page_ipad_pro',
      isFinal: false,
      sizeDp: iPadProScreenSize,
      density: 2,
    );

    // Créer le wrapper pour iPad Pro 2e génération
    final widgetPro2 = getScreenWrapper(
      child: FichesPaieChild(),
      locale: Locale('fr'),
      isAndroid: false,
    );

    // Prendre la capture d'écran pour iPad Pro 2e génération
    await takeScreenshot(
      tester: tester,
      widget: widgetPro2,
      pageName: 'profile_page_ipad_pro_2nd_gen',
      isFinal: false,
      sizeDp: iPadPro2ScreenSize,
      density: 2,
    );
  });
}