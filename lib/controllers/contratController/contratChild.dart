import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/apihelper.dart';
import '../../models/contrat.dart';

class ContratChild extends StatefulWidget {
  @override
  _ContratChildState createState() => _ContratChildState();
}

class _ContratChildState extends State<ContratChild> {
  List<Contrat>? contrats;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    final loadedContrats = await AuthApi.getContrats();

    setState(() {
      contrats = loadedContrats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : contrats == null || contrats!.isEmpty
          ? Center(child: Text("Pas de contrats"))
          : AnimationLimiter(
        child: ListView.builder(
          itemCount: contrats!.length,
          padding: EdgeInsets.all(_w / 30),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemBuilder: (BuildContext c, int i) {
            final contrat = contrats![i];
            return AnimationConfiguration.staggeredList(
              position: i,
              delay: const Duration(milliseconds: 100),
              child: SlideAnimation(
                duration: const Duration(milliseconds: 2500),
                curve: Curves.fastLinearToSlowEaseIn,
                horizontalOffset: _w * 0.075,
                verticalOffset: _h * 0.375,
                child: ContratItem(width: _w, contrat: contrat),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ContratItem extends StatelessWidget {
  final double width;
  final Contrat contrat;

  ContratItem({required this.width, required this.contrat});

  Future<void> downloadFile(String url, String fileName, BuildContext context) async {
    await requestPermissions();
    final status = await Permission.storage.request();

    if (status.isGranted) {
      final baseDir = await getExternalStorageDirectory(); // Get the directory path
      final localPath = baseDir!.path + '/Download';

      final savedDir = Directory(localPath);
      if (!await savedDir.exists()) {
        await savedDir.create(recursive: true);
      }

      // Provide the savedDir parameter to the FlutterDownloader.enqueue method
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: localPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission nécessaire'),
          content: Text('Cette application a besoin de la permission de stockage pour télécharger des fichiers. Veuillez activer la permission dans les paramètres de l\'application.'),
          actions: <TextButton>[
            TextButton(
              child: Text('Ouvrir les paramètres'),
              onPressed: () => openAppSettings(),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La permission de stockage est nécessaire pour télécharger des fichiers.'),
        ),
      );
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        await Permission.storage.request();
      }
    } else if(Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        await Permission.photos.request();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double iconSize = width * 0.075;

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PDFScreen(url: 'https://appariteur.com/admins/documents/${contrat.nameFichier}'),
              ),
            );
          },
          child:  Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: iconSize),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: Text('${contrat!.typeContrat} ', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Icon(Icons.check_circle, color: Colors.green, size: iconSize)
                  ],
                ),
                SizedBox(height: width * 0.025),
                Text('Valide jusqu\'au: ${contrat.dateFinContrat}', style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: width * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        downloadFile('https://appariteur.com/admins/documents/${contrat.nameFichier}', contrat.nameFichier,context);
                      },
                      icon: Icon(Icons.download, color: Theme.of(context).primaryColor),
                      label: Text('Télécharger', style: Theme.of(context).textTheme.bodyLarge),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: width * 0.02, horizontal: width * 0.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      ),
                    ),
                    Row(
                      children: [
                        Text('Voir ', style: Theme.of(context).textTheme.bodyLarge),
                        Icon(Icons.remove_red_eye, color: Theme.of(context).primaryColor),
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
        title: const Text('Document'),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
