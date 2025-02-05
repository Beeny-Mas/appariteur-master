import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class VersionCheck {
  static const String PLAYSTORE_URL = 'https://play.google.com/store/apps/details?id=com.h24consult.appariteur';
  static const String APPSTORE_URL = 'https://apps.apple.com/fr/app/appariteur/id6621275868';

  static Future<void> checkVersion(BuildContext context) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await http.get(
        Uri.parse('https://appariteur.com/api/versions.php?platform=$platform'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final versionData = data['data'];
          final String latestVersion = versionData['latest_version'];
          final bool forceUpdate = versionData['force_update'];
          final String storeUrl = versionData['store_url'];
          final String minVersion = versionData['min_version'];

          if (_shouldUpdate(currentVersion, minVersion) && forceUpdate) {
            if (context.mounted) {
              _showForceUpdateDialog(context, storeUrl);
            }
          }
        }
      }
    } catch (e) {
      print('Error checking version: $e');
    }
  }

  static bool _shouldUpdate(String currentVersion, String minVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> minimum = minVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < current.length; i++) {
      if (minimum[i] > current[i]) return true;
      if (minimum[i] < current[i]) return false;
    }
    return false;
  }

  static void _showForceUpdateDialog(BuildContext context, String storeUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Mise à jour requise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.system_update,
                size: 50,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Une nouvelle version de l\'application est disponible. Cette mise à jour est obligatoire pour continuer à utiliser l\'application.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(storeUrl))) {
                  await launchUrl(
                    Uri.parse(storeUrl),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: const Text('Mettre à jour maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}