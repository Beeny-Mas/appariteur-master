import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/apihelper.dart';
import '../../models/userdoc.dart';

class DocumentUploadPage extends StatefulWidget {
  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  String? _pdfPath;
  int? _selectedDocType;
  bool _uploading = false;
  bool _isSnackBarVisible = false;
  final Map<int, String> _docTypes = {
    1: 'Pièce d\'identité',
    2: 'Titre de séjour',
    3: 'Relevé d\'identité bancaire (RIB)',
    4: 'Attestation Sécurité sociale',
    5: 'Contrat',
    15: 'Autre'
  };
  List<UserDoc> userDocs = [];
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _selectedFile = File(file.path!);
        if (file.extension == 'pdf') {
          _pdfPath = file.path;
        }
      });
    }
  }
  Future<void> ShowUserDoc() async {
    final userDoc = await AuthApi.getUserDocuments();
    if (userDoc != null) {
      setState(() {
        userDocs = userDoc.toList();
      });
    }
  }
  Future<void> _uploadFile() async {
    setState(() {
      _uploading = true;
    });

    try {
      if (_selectedFile != null && _selectedDocType != null) {
        final success = await AuthApi.uploadDocument(_selectedFile, _selectedDocType.toString());
        if (success == true) {
          _showCustomSnackBar('Document enregistré avec succès');
        } else {
          _showCustomSnackBar('Echec de l\'enregistrement du document');
        }
      } else {
        _showCustomSnackBar('Sélectionnez un fichier et un type de document!');
      }
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  void _showCustomSnackBar(String message) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16.0,
        left: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
      _isSnackBarVisible = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Importer un Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_w / 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Type de document',
                style: TextStyle(fontSize: _w / 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              SizedBox(height: _w / 30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: _w / 30, vertical: _w / 60),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_w / 60),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedDocType,
                    hint: Text('Selectionner un type de document'),
                    isExpanded: true,
                    items: _docTypes.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDocType = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: _w / 20),
              InkWell(
                onTap: _pickFile,
                child: DottedBorder(
                  color: Colors.blue,
                  radius: Radius.circular(_w / 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(_w / 60)),
                    child: Container(
                      height: _w * 0.5,
                      color: Colors.grey[200],
                      child: _selectedFile != null
                          ? _selectedFile!.path.endsWith('.pdf')
                          ? PDFView(
                        filePath: _pdfPath,
                        enableSwipe: true,
                        swipeHorizontal: true,
                        autoSpacing: false,
                        pageFling: false,
                        pageSnap: false,
                        defaultPage: 0,
                        fitPolicy: FitPolicy.BOTH,
                      )
                          : Image.file(_selectedFile!, fit: BoxFit.cover)
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, color: Colors.blue, size: _w / 10),
                          Text('Appuyer pour sélectionner un fichier', style: TextStyle(color: Colors.blue, fontSize: _w / 25)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: _w / 20),
              ElevatedButton(
                onPressed: _uploading ? null : _uploadFile, // Disable button while uploading
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: _w / 30),
                  child: _uploading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text('Veuillez patienter...'),
                    ],
                  )
                      : Text('Importer le Document', style: TextStyle(fontSize: _w / 20, color: Colors.white)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_w / 60),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorder extends StatelessWidget {
  final Color color;
  final Radius radius;
  final Widget child;

  const DottedBorder({
    Key? key,
    required this.color,
    required this.radius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedBorderPainter(color: color),
      child: child,
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double dashWidth = 4.0;
  final double dashSpace = 4.0;

  DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var path = Path();
    double x = 0, y = 0;
    while (x < size.width) {
      path.moveTo(x, 0);
      path.lineTo(x + dashWidth, 0);
      x += dashWidth + dashSpace;
    }

    while (y < size.height) {
      path.moveTo(size.width, y);
      path.lineTo(size.width, y + dashWidth);
      y += dashWidth + dashSpace;
    }

    x = size.width;
    while (x > 0) {
      path.moveTo(x, size.height);
      path.lineTo(x - dashWidth, size.height);
      x -= dashWidth + dashSpace;
    }

    y = size.height;
    while (y > 0) {
      path.moveTo(0, y);
      path.lineTo(0, y - dashWidth);
      y -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) => false;
}
