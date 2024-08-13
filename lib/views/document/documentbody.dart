import 'dart:io';

import 'package:appariteur/views/document/adddDocument.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/apihelper.dart';
import '../../models/userdoc.dart';
import '../notif/notifScreen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../widgets/addonglobal/topbar.dart';

class DocumentShild extends StatefulWidget {
  const DocumentShild({Key? key}) : super(key: key);

  @override
  State<DocumentShild> createState() => _DocumentShildState();
}

class _DocumentShildState extends State<DocumentShild> {
  List<UserDoc> userDocs = [];

  @override
  void initState() {
    super.initState();
    ShowUserDoc();
  }

  Future<void> ShowUserDoc() async {
    final userDoc = await AuthApi.getUserDocuments();
    if (userDoc != null) {
      setState(() {
        userDocs = userDoc.toList();
      });
    }
  }

  Future<void> confirmAndDeleteDocument(String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer le document'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce document? Cette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldDelete) {
      final success = await AuthApi.deleteUserDocument(docId);
      if (success) {
        setState(() {
          userDocs.removeWhere((document) => document.docId == docId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document supprimé avec succès.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression du document.')));
      }
    }
  }

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
            print("Fichier téléchargé à : $path");
          },
        );
      } else if (Platform.isIOS) {
        Dio dio = Dio();
        await dio.download(url, savePath, onReceiveProgress: (received, total) {
          if (received == total) {
            print("Fichier téléchargé à : $savePath");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                showCloseIcon: true,
                duration: Duration(seconds: 8),
                content: Text('Fichier "$fileName" téléchargé avec succès dans : $savePath.'),
                action: SnackBarAction(
                  label: 'Ouvrir',
                  onPressed: () {
                    print("Tentative d'ouverture du fichier à : $savePath");
                    OpenFile.open(savePath).then((value) => print("Résultat de l'ouverture du fichier : ${value.message}"));
                  },
                ),
              ),
            );

          }
        });
      }
    } catch (e) {
      print("Erreur lors du téléchargement du fichier : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléchargement : $e'),
        ),
      );
    }
  }




  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
      } else if (await Permission.manageExternalStorage.isGranted) {
      } else {
        if (await Permission.storage.isPermanentlyDenied) {
          await openAppSettings();
        } else {
          var result = await Permission.manageExternalStorage.request();
          if (result.isGranted) {
          } else {
          }
        }
      }
    }else if(Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        await Permission.photos.request();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

    return Scaffold(
        floatingActionButton: FloatingActionButton( child: Icon(Icons.add), onPressed: (){Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  DocumentUploadPage()),
        );}),
        appBar: TopBarS(
          showBackButton: true,
          onNotificationPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotifScreen()),
            );
          },
          PageName: "Mes documents",
        ),

        backgroundColor: Colors.white,
        body:RefreshIndicator(
          onRefresh: () async {
            await ShowUserDoc();
          },child : AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(25),
            itemCount: userDocs.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = userDocs[index];
              return AnimationConfiguration.staggeredList(
                duration: const Duration(milliseconds: 500),
                position: index,
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 2500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  horizontalOffset: 30,
                  verticalOffset: 300.0,
                  child: FlipAnimation(
                    flipAxis: FlipAxis.y,
                    duration: const Duration(milliseconds: 3000),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      margin: EdgeInsets.only(bottom: _w / 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFScreen(url: 'https://appariteur.com/appa/admins/documents/${doc.docName}'),
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
                                    child: Text(doc.typeDoc, style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => downloadFile('https://appariteur.com/appa/admins/documents/${doc.docName}', '${doc.docName}.pdf', context),
                                    icon: Icon(Icons.download, color: Theme.of(context).primaryColor),
                                    label: Text('Télécharger', style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFScreen(url: 'https://appariteur.com/appa/admins/documents/${doc.docName}'),
                                      ),
                                    ),
                                    icon: Icon(Icons.remove_red_eye, color: Theme.of(context).primaryColor),
                                    label: Text('Voir', style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmAndDeleteDocument(doc.docId),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        )
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