import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/apihelper.dart';
import '../../models/user.dart';

class CarteController extends StatefulWidget {
  const CarteController({Key? key}) : super(key: key);

  @override
  _CarteControllerState createState() => _CarteControllerState();
}

class _CarteControllerState extends State<CarteController> {
  UserData? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _preventScreenshots();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await AuthApi.getLocalUserData();
      print('Données récupérées dans _loadUserData: $data');
      print('appariteurId value in API response: ${data?.appariteurId}');
      print('appariteurId type: ${data?.appariteurId?.runtimeType}');
      
      // Vérifier si les données sont complètes pour debug
      if (data != null) {
        final userDataJson = data.toJson();
        print('UserData complète: $userDataJson');
      }
      
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  void _preventScreenshots() {
    try {
      // Empêcher les captures d'écran sur Android
      if (Platform.isAndroid) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        // Commentez temporairement cette ligne pour éviter l'erreur
        // const MethodChannel('flutter/platform_channel')
        //     .invokeMethod('disableScreenshots');
      }
      // Empêcher les captures d'écran sur iOS
      if (Platform.isIOS) {
        // Commentez temporairement cette ligne pour éviter l'erreur
        // const MethodChannel('flutter/platform_channel')
        //     .invokeMethod('disableScreenshots');
      }
    } catch (e) {
      print('Erreur lors de la désactivation des captures d\'écran: $e');
    }
  }

  @override
  void dispose() {
    // Réactiver les captures d'écran
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
          overlays: SystemUiOverlay.values);
      const MethodChannel('flutter/platform_channel')
          .invokeMethod('enableScreenshots');
    }
    if (Platform.isIOS) {
      const MethodChannel('flutter/platform_channel')
          .invokeMethod('enableScreenshots');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return Center(
        child: Text(
          'Impossible de charger les données utilisateur',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    // Ajouter ce log pour déboguer
    print('appariteurId dans build: ${userData?.appariteurId}');
    print('appariteurId type in build: ${userData?.appariteurId?.runtimeType}');
    // Debug entire userData object
    print('userData in build: ${userData?.toJson()}');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 500, // Largeur fixe pour la carte
            height: 280, // Hauteur fixe pour la carte
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête rouge avec logo et titre
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Fond rouge
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                          ),
                        ),
                        // Séparation oblique blanche
                        ClipPath(
                          clipper: DiagonalClipper(),
                          child: Container(
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                        // Logo
                        Positioned(
                          left: 10,
                          top: 5,
                          child: Image.asset(
                            'assets/images/logo 2.jpg',
                            height: 30,
                          ),
                        ),
                        // Texte CARTE PROFESSIONNELLE
                        Positioned(
                          right: 100,
                          top: 10,
                          child: Text(
                            'CARTE PROFESSIONNELLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Corps de la carte
                  Expanded(
                    child: Row(
                      children: [
                        // Partie gauche avec photo et triangle rouge
                        Container(
                          width: 150,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Triangle rouge en bas à gauche
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: CustomPaint(
                                  size: Size(150, 80),
                                  painter: TrianglePainter(),
                                ),
                              ),
                              
                              // Photo de profil avec fond transparent pour laisser voir le triangle
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Stack(
                                    children: [
                                      // Photo avec opacité pour laisser voir le triangle
                                      Positioned.fill(
                                        child: userData?.image != null && userData!.image!.isNotEmpty
                                          ? Image.network(
                                              'https://appariteur.com/appa/admins/user_images/${userData!.image}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300]!.withOpacity(0.8),
                                                  child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey[300]!.withOpacity(0.8),
                                              child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Partie droite avec informations personnelles
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SURVEILLANT D\'EXAMENS',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                _buildInfoRow('NOM :', userData?.name?.split(' ').last ?? 'N/A'),
                                SizedBox(height: 2.0),
                                _buildInfoRow('PRÉNOM :', userData?.name?.split(' ').first ?? 'N/A'),
                                SizedBox(height: 2.0),
                                // Vérifier si appariteurId existe et n'est pas vide
                                _buildInfoRow('ID APPARITEUR :', userData?.appariteurId != null && userData!.appariteurId!.isNotEmpty ? userData!.appariteurId! : 'N/A'),
                                SizedBox(height: 6.0),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 14.0, color: Colors.black54),
                                    SizedBox(width: 4.0),
                                    Text(
                                      userData?.tel ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    Icon(Icons.email, size: 14.0, color: Colors.black54),
                                    SizedBox(width: 4.0),
                                    Text(
                                      'INFO@APPARITEUR.COM',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                Spacer(),
                                
                                // QR code à droite
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: QrImageView(
                                    data: 'https://appariteur.com',
                                    version: QrVersions.auto,
                                    size: 60.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Pied de page avec logo et informations de contact
                  Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Logo à gauche
                        Image.asset(
                          'assets/images/logo2sansfond.png',
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10.0),
                        
                        // Informations de contact avec icônes
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Site web
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.language, size: 12.0, color: Colors.white),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'www.appariteur.fr',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Téléphone
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, size: 12.0, color: Colors.white),
                                  SizedBox(width: 4.0),
                                  Text(
                                    '0148153667',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Email
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.email, size: 12.0, color: Colors.white),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'info@appariteur.com',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4.0),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

// Classe pour dessiner le triangle rouge en bas à gauche
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Classe pour créer une séparation diagonale
class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(size.width - 20, 0)
      ..lineTo(size.width - 40, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
