import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/apihelper.dart';
import '../../main.dart';
import '../../models/contrat.dart';
import '../../models/fichepaie.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class FichesPaieChild extends StatefulWidget {
  @override
  _FichesPaieChildState createState() => _FichesPaieChildState();
}

class _FichesPaieChildState extends State<FichesPaieChild> {
  List<FichePaie>? fichesPaie;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    loadFichesPaie();
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your icon name

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    print("Notification payload received: $payload");
    if (payload != null) {
      print("Attempting to open file at: $payload");
      final result = OpenFile.open(payload);
      result.then((value) => print("OpenFile result: ${value.message}"));
    }
  }

  Future<void> loadFichesPaie() async {
    FlutterDownloader.initialize();
    final loadedFichesPaie = await AuthApi.getFichesPaie();
    setState(() {
      fichesPaie = loadedFichesPaie;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder<List<FichePaie>?>(
        future: AuthApi.getFichesPaie(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des fiches'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Pas de fiches"));
          } else {
            return AnimationLimiter(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                padding: EdgeInsets.all(_w / 30),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext c, int i) {
                  final fiche = snapshot.data![i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      horizontalOffset: 30,
                      verticalOffset: 300.0,
                      child: ListItem(width: _w, fiche: fiche),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final double width;
  final FichePaie fiche;

  ListItem({required this.width, required this.fiche});

  Future<void> downloadFile(String url, String fileName, BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$fileName';

    try {
      if (Platform.isAndroid) {
        await FileDownloader.downloadFile(
          url: url,
          name: fileName,
          notificationType: NotificationType.all,
          downloadDestination: DownloadDestinations.publicDownloads,
          onDownloadCompleted: (String path) {
            print("File downloaded to: $path");
          },
        );
      } else if (Platform.isIOS) {
        Dio dio = Dio();
        await dio.download(url, savePath, onReceiveProgress: (received, total) {
          if (received == total) {
            print("File downloaded to: $savePath");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                duration: Duration(seconds: 8),
                content: Text('Fichier "$fileName" téléchargé avec succès dans : $savePath.'),
                action: SnackBarAction(
                  label: 'Ouvrir',
                  onPressed: () {
                    print("Attempting to open file at: $savePath");
                    OpenFile.open(savePath).then((value) => print("OpenFile result: ${value.message}"));
                  },
                ),
              ),
            );
            _showDownloadNotification(fileName, savePath);
          }
        });
      }
    } catch (e) {
      print("Error during file download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement: $e'),
        ),
      );
    }
  }

  Future<void> _showDownloadNotification(
      String fileName, String filePath) async {
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(iOS: iosPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Téléchargement terminé',
      'Fichier "$fileName" téléchargé avec succès. Ouvrir ?',
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipAnimation(
      duration: const Duration(milliseconds: 3000),
      curve: Curves.fastLinearToSlowEaseIn,
      flipAxis: FlipAxis.y,
      child: Card(
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.only(bottom: width / 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFScreen(
                  url: 'https://appariteur.com/admins/documents/${fiche.fichier}'),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('${fiche.mois} ${fiche.annee}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Icon(Icons.check_circle, color: Colors.green)
                  ],
                ),
                SizedBox(height: 10),
                Text('Créée le: ${fiche.dateCreate}',
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        downloadFile(
                            'https://appariteur.com/admins/documents/${fiche.fichier}',
                            fiche.fichier,
                            context);
                      },
                      icon: Icon(Icons.download,
                          color: Theme.of(context).primaryColor),
                      label: Text('Télécharger',
                          style: Theme.of(context).textTheme.bodyMedium),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                      ),
                    ),
                    Row(
                      children: [
                        Text('Voir ',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Icon(Icons.remove_red_eye,
                            color: Theme.of(context).primaryColor),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final String url;

  const PDFScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche de Paie'),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}

class ContratChild extends StatefulWidget {
  @override
  _ContratChildState createState() => _ContratChildState();
}

class _ContratChildState extends State<ContratChild> {
  List<Contrat>? contrats;

  @override
  void initState() {
    super.initState();
    loadContrats();
  }

  Future<void> loadContrats() async {
    FlutterDownloader.initialize();
    final loadedContrats = await AuthApi.getContrats();
    setState(() {
      contrats = loadedContrats;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder<List<Contrat>?>(
        future: AuthApi.getContrats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des contrats'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Pas de contrats"));
          } else {
            return AnimationLimiter(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                padding: EdgeInsets.all(_w / 30),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext c, int i) {
                  final contrat = snapshot.data![i];
                  return AnimationConfiguration.staggeredList(
                    position: i,
                    delay: const Duration(milliseconds: 100),
                    child: SlideAnimation(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.fastLinearToSlowEaseIn,
                      horizontalOffset: 30,
                      verticalOffset: 300.0,
                      child: ListItemContrat(width: _w, contrat: contrat),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class ListItemContrat extends StatelessWidget {
  final double width;
  final Contrat contrat;

  ListItemContrat({required this.width, required this.contrat});

  Future<void> downloadFile(String url, String fileName, BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$fileName';

    try {
      if (Platform.isAndroid) {
        await FileDownloader.downloadFile(
          url: url,
          name: fileName,
          notificationType: NotificationType.all,
          downloadDestination: DownloadDestinations.publicDownloads,
          onDownloadCompleted: (String path) {
            print("File downloaded to: $path");
          },
        );
      } else if (Platform.isIOS) {
        Dio dio = Dio();


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(color: Colors.blue,),
                  SizedBox(width: 20),
                  Expanded(child: Text("Téléchargement en cours...")),
                ],
              ),
            );
          },
        );

        await dio.download(url, savePath, onReceiveProgress: (received, total) {
          if (received == total) {
            print("File downloaded to: $savePath");

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                duration: Duration(seconds: 10),
                content: Text('Fichier "$fileName" téléchargé avec succès dans : $savePath.'),
                action: SnackBarAction(
                  label: 'Ouvrir',
                  onPressed: () {
                    print("Attempting to open file at: $savePath");
                    OpenFile.open(savePath).then((value) => print("OpenFile result: ${value.message}"));
                  },
                ),
              ),
            );

          }
        });
      }
    } catch (e) {
      // Fermer l'indicateur de téléchargement en cas d'erreur
      if (Platform.isIOS) {
        Navigator.pop(context);
      }

      print("Error during file download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement: $e'),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return FlipAnimation(
      duration: const Duration(milliseconds: 3000),
      curve: Curves.fastLinearToSlowEaseIn,
      flipAxis: FlipAxis.y,
      child: Card(
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.only(bottom: width / 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFScreen(
                  url: 'https://appariteur.com/appa/admins/documents/${contrat.nameFichier}'),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('${contrat.typeContrat} ',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Icon(Icons.check_circle, color: Colors.green)
                  ],
                ),
                SizedBox(height: 10),
                Text('Valide jusqu\'au: ${contrat.dateFinContrat}',
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        downloadFile(
                            'https://appariteur.com/appa/admins/documents/${contrat.nameFichier}',
                            contrat.nameFichier,
                            context);
                      },
                      icon: Icon(Icons.download,
                          color: Theme.of(context).primaryColor),
                      label: Text('Télécharger',
                          style: Theme.of(context).textTheme.bodyMedium),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                      ),
                    ),
                    Row(
                      children: [
                        Text('Voir ',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Icon(Icons.remove_red_eye,
                            color: Theme.of(context).primaryColor),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

