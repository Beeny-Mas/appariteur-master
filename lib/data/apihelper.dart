

import 'dart:convert';


import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contrat.dart';
import '../models/disponibilites.dart';
import '../models/fichepaie.dart';
import '../models/missionuser.dart';
import '../models/planning.dart';
import '../models/user.dart';
import '../models/userdoc.dart';
import '../models/userinfo.dart';


class AuthApi {
  static UserData? _loggedUserData;
  static String? tokenVar;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  static Future<UserData?> login(String email, String password) async {
    try {
      const url = 'https://appariteur.com/api/users/login.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailUser': email, 'passwordUser': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['data'];
          tokenVar = data['token'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (tokenVar != null) {
            prefs.setString('token', tokenVar!);
          }
          if (userData['user_id'] != null) {
            prefs.setString('userId', userData['user_id']);
          }
          if (userData['appariteur_id'] != null) {
            prefs.setString('appariteurId', userData['appariteur_id']);
          }

          // Gérer les autres champs
          userData.forEach((key, value) {
            if (value != null && key != 'user_id' && key != 'appariteur_id' && key != 'token') {
              prefs.setString(key, value.toString());
            }
          });

          return UserData(
            userId: userData['user_id'],
            appariteurId: userData['appariteur_id'],
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            tel: userData['tel'] ?? '',
            sexe: userData['sexe'] ?? '',
            image: userData['image'] ?? '',
            adresse: userData['adresse'] ?? '',
            datenais: userData['datenais'] ?? '',
            lieunais: userData['lieunais'] ?? '',
            rue: userData['rue'] ?? '',
            codepostal: userData['codepostal'] ?? '',
            ville: userData['ville'] ?? '',
            pays: userData['pays'] ?? '',
            niveau: userData['niveau'] ?? '',
            user: userData['user'] ?? '',
            token: prefs.getString('token'),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la connexion à l\'API : $e');
    }
    return null;
  }

  static Future<bool> deleteAccount() async {
    final token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return false;
    }

    const url = 'https://appariteur.com/api/users/deleteuser.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Account deactivated successfully');
          return true;
        } else {
          print('Failed to deactivate account: ${responseData['message']}');
        }
      } else {
        print('Failed to deactivate account. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deactivating account: $e');
    }

    return false;
  }

  static Future<UserData?> getLocalUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) return null; // Si l'utilisateur n'est pas connecté

    return UserData(
      userId: userId,
      appariteurId: prefs.getString('appariteurId') ?? '',
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      tel: prefs.getString('tel') ?? '',
      sexe: prefs.getString('sexe') ?? '',
      image: prefs.getString('image') ?? '',
      adresse: prefs.getString('adresse') ?? '',
      datenais: prefs.getString('datenais') ?? '',
      lieunais: prefs.getString('lieunais') ?? '',
      rue: prefs.getString('rue') ?? '',
      codepostal: prefs.getString('codepostal') ?? '',
      ville: prefs.getString('ville') ?? '',
      pays: prefs.getString('pays') ?? '',
      niveau: prefs.getString('niveau') ?? '',
      user:prefs.getString('user') ?? '',

    );
  }
  static Future<UserData?> getOnlineUserData() async {

    final token = await getToken();
    if (token == null) return null;

    const url = 'https://appariteur.com/api/users/profile.php';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final userData = data['data'];
          // Mettre à jour les SharedPreferences ici
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userData.forEach((key, value) {
            if (value != null) {
              prefs.setString(key, value.toString());
            }
          });
          return UserData.fromJson(userData);
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des données de l\'utilisateur : $e');
    }
    return null;
  }
  static Future<bool?> updateProfile(UserData userData, io.File? imageFile) async {
    print("API updateProfile: Début de l'appel API");
    final token = await getToken();  // Implement getToken() according to your auth logic
    if (token == null) {
      print('Error: Token is null');
      return null;
    }
    const url = 'https://appariteur.com/api/users/profile.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['userId']=userData.userId!
        ..fields['appariteurId']=userData.appariteurId!
        ..fields['name'] = userData.name!
        ..fields['email'] = userData.email!
        ..fields['tel'] = userData.tel!
        ..fields['sexe'] = userData.sexe!
        ..fields['adresse'] = userData.adresse!
        ..fields['datenais'] = userData.datenais!
        ..fields['lieunais'] = userData.lieunais!
        ..fields['codepostal'] = userData.codepostal!
        ..fields['pays'] = userData.pays!;

      if (imageFile != null && await imageFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      } else {
        print('Image file does not exist or is not selected');
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        // Check the response structure and handle accordingly
        if (responseData['success']) {
          print('Profile updated successfully!');
          return true;
        } else {
          print('Server response: ${responseData['message'] ?? 'No specific error message.'}');
        }
      } else {
        print('Failed to update profile, status code: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
  static Future<bool> resetPassword(String email) async {
    try {
      const url = 'https://appariteur.com/api/users/passwordreset.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailUser': email}),
      );

      if (response.statusCode ==  200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Le code de réinitialisation a été envoyé à l\'adresse email $email.');
          return true;
        } else {
          print('Erreur lors de la réinitialisation du mot de passe : ${data['error'] ?? 'Aucun message d\'erreur spécifique.'}');
        }
      } else {
        print('Erreur lors de la réinitialisation du mot de passe, code de statut : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe : $e');
    }
    return false;
  }

  static Future<UserInfo?> InfoUser() async {
    final token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return null;
    }
    const url = 'https://appariteur.com/api/users/infos_g.php';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Convertir la réponse en string
      String responseBody = response.body;

      // Nettoyer la réponse des caractères numériques au début
      responseBody = responseBody.replaceFirst(RegExp(r'^\d+'), '');

      // Vérifier si la chaîne commence maintenant par {
      if (!responseBody.trim().startsWith('{')) {
        print('Erreur: La réponse ne commence pas par { après nettoyage');
        return null;
      }

      // Parser le JSON nettoyé
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      // Vérifier si la réponse est un succès
      if (responseData['success'] != true) {
        print('Erreur: La réponse indique un échec');
        return null;
      }

      final Map<String, dynamic> userData = responseData['data'];

      // Créer l'objet UserInfo avec les données
      final UserInfo userInfo = UserInfo(
        heureWeek: userData['heure_week'],
        heureMonth: userData['heure_month'],
        heureYear: userData['heure_year'],
        effeMis: userData['effe_mis'],
      );

      print('Données utilisateur récupérées avec succès: $userInfo');
      return userInfo;

    } catch (e) {
      print('Erreur lors du traitement des données: $e');
      return null;
    }
  }

  static Future<bool?> uploadDocument(io.File? documentFile, String docType) async {
    final token = await getToken(); // Implement this method to get the current user's token
    if (token == null) {
      print('Error: Token is null');
      return null;
    }
    const url = 'https://appariteur.com/api/users/document.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['doc_type'] = docType;

      if (documentFile != null && await documentFile.exists()) {
        request.files.add(await http.MultipartFile.fromPath('fileDoc', documentFile.path));
      } else {
        print('Document file does not exist or is not selected');
        return null;
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        if (responseData['success']) {
          print('Document uploaded successfully!');
          return true;
        } else {
          print('Server response: ${responseData['message'] ?? 'No specific error message.'}');
        }
      } else {
        print('Failed to upload document, status code: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      print('Error uploading document: $e');
      return false;
    }
  }

  static Future<List<UserDoc>?> getUserDocuments() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }
      final response = await http.get(
        Uri.parse('https://appariteur.com/api/users/document.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> documentsData = jsonDecode(response.body)['data'];

        final List<UserDoc> documentsList =
        documentsData.map((data) => UserDoc.fromJson(data)).toList();

        return documentsList;
      }
    } catch (e) {
      print('Erreur lors de la récupération des documents : $e');
    }

    return null;
  }


  static Future<MissionEffUserResult?> getMissionsEffectuees(String dateStart, String dateEnd) async {
    const endpoint = 'https://appariteur.com/api/users/missioneffectuee.php';
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }

      final queryParameters = {
        'date_start': dateStart,
        'date_end': dateEnd,
      };

      final uri = Uri.parse(endpoint).replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result']['success'] == true) {
          List<Mission> missions = [];
          for (var missionData in data['result']['data']) {
            missions.add(Mission.fromJson(missionData));
          }
          String? totalHours = data['result']['total_heure']; // Utilisation de String? pour un champ nullable
          return MissionEffUserResult(missions: missions, totalHours: totalHours);
        } else {
          print("API returned success false");
        }
      } else {
        print("Failed to load missions. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching mission data: $e');
    }
    return null;
  }

  static Future<List<FichePaie>?> getFichesPaie() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }
      const url = 'https://appariteur.com/api/users/fichepaie.php';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var fichesPaieData = json.decode(utf8.decode(response.bodyBytes));

        if (fichesPaieData['success'] == true) {
          final List<dynamic> fichesPaieInfo = fichesPaieData['data'];

          if (fichesPaieInfo.isEmpty) {
            // Aucune fiche de paie à afficher
            return null;
          }

          final List<FichePaie> fichesPaieList = fichesPaieInfo.map((ficheData) {
            return FichePaie(
              id: ficheData['id'],
              mois: ficheData['mois'],
              annee: ficheData['annee'],
              fichier: ficheData['fichier'],
              dateCreate: ficheData['Datecreate'],
            );
          }).toList();

          print(fichesPaieList); // Vous pouvez imprimer les fichesPaieList ici si nécessaire
          return fichesPaieList;
        }
      } else {
        print('Erreur HTTP lors de la récupération des fiches de paie. Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la connexion à l\'API pour les fiches de paie : $e');
    }

    return null; // Gérer les erreurs comme vous le souhaitez
  }
  static Future<bool> signUp(UserData userData) async {
    try {
      const url = 'https://appariteur.com/api/users/register.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nameUser': userData.name,
          'emailUser': userData.email,
          'telUser': userData.tel,
          'sexeUser': userData.sexe,
          'passwordUser': userData.password,
          'datenaisUser': userData.datenais,
          'lieunaisUser': userData.lieunais,
          'rueAp': userData.rue,
          'villeAp': userData.ville,
          'paysAp': userData.pays,
        }),
      );

      if (response.statusCode ==  200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Inscription réussie!');
          return true;
        } else {
          print('Erreur lors de l\'inscription: ${data['message'] ?? 'Aucun message d\'erreur spécifique.'}');
        }
      } else {
        print('Erreur lors de l\'inscription, code de statut: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à l\'API d\'inscription: $e');
    }
    return false;
  }


  static Future<List<Planning>?> getPlanningData() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }

      const url = 'https://appariteur.com/api/users/planning.php';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> planningData = jsonDecode(response.body);

        if (planningData.isNotEmpty) {
          final List<Planning> eventsList = planningData.map((eventData) {
            return Planning.fromJson(eventData);
          }).toList();
          print(eventsList);
          return eventsList;
        } else {
          print('Planning data is empty');
          return <Planning>[];
        }
      } else {
        print('Failed to fetch planning data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching planning data: $e');
    }

    return null;
  }



  static Future<bool> updatePlanning(Planning planning, String salle, String heureDebut, String heureFin) async {
    final token = await getToken();
    if (token == null) {
      print('Token is null');
      return false;
    }

    const url = 'https://appariteur.com/api/users/planning.php';
    Map<String, dynamic> requestBody = {

      'updates':
      {
        'name_etabli': planning.nameEtabli,
        'salle': salle,
        'date_pres': planning.datePres,
        'heure_debut': heureDebut,
        'heure_fin': heureFin
      }


    };

    String jsonBody = jsonEncode(requestBody);
    print('Sending update object: $jsonBody');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Response data: $responseData');
        return responseData['success'];
      } else {
        print('Failed to update planning: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating planning: $e');
      return false;
    }
  }



  static Future<List<Contrat>?> getContrats() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }

      const url = 'https://appariteur.com/api/users/contrat.php';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var contratsData = json.decode(utf8.decode(response.bodyBytes));

        if (contratsData['success'] == true) {
          final List<dynamic> contratsInfo = contratsData['data'];

          if (contratsInfo.isEmpty) {
            // Aucun contrat à afficher
            return null;
          }

          final List<Contrat> contratsList = contratsInfo.map((contratData) {
            return Contrat(
              idContratApp: contratData['Id_contrat_app'],
              appariteurId: contratData['appariteur_id'],
              typeContrat: contratData['TypeContrat'],
              dateEmbauche: contratData['DateEmbauche'],
              dateFinContrat: contratData['DateFinContrat'],
              dateEdition: contratData['DateEdition'],
              disponibilite: contratData['Disponibilite'],
              nbrHeure: contratData['nbr_heure'],
              montantHeure: contratData['montant_heure'],
              nameFichier: contratData['name_fichier'],
            );
          }).toList();

          print(contratsList); // Vous pouvez imprimer les contratsList ici si nécessaire
          return contratsList;
        }
      } else {
        print('Erreur HTTP lors de la récupération des contrats. Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la connexion à l\'API pour les contrats : $e');
    }

    return null; // Gérer les erreurs comme vous le souhaitez
  }

  static Future<void> sendDisponibilites(List<Map<String, dynamic>> disponibilites) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Error: Token is null');
        return null;
      }
      const url = 'https://appariteur.com/api/users/disponibilites.php';
      final Map<String, dynamic> requestBody = {'updates': disponibilites};
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Traitement de la réponse
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Disponibilités ajoutées avec succès');
        } else {
          print('Erreur lors de l\'ajout des disponibilités');
        }
      } else {
        print('Failed to add disponibilites. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending disponibilites: $e');
    }
  }
  static Future<bool> cancelMission(String missionId) async {
    final token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return false;
    }

    final url = 'https://appariteur.com/api/users/planning.php?mission_id=$missionId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('Mission cancelled successfully');
        return true;
      } else {
        print('Server responded with error: ${responseData['message']}');
        return false;
      }
    } else {
      print('HTTP Error while cancelling mission. Status Code: ${response.statusCode}');
      return false;
    }
  }
  static Future<List<Disponibilite>?> getDisponibilites() async {
    final token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return null;
    }
    const url = 'https://appariteur.com/api/users/disponibilites.php';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var disponibilitesData = json.decode(utf8.decode(response.bodyBytes));
        if (disponibilitesData['success'] == true) {
          final List<dynamic> disponibilitesInfo = disponibilitesData['result'];

          if (disponibilitesInfo.isEmpty) {
            return null;
          }

          final List<Disponibilite> disponibilitesList = disponibilitesInfo.map((disponibiliteData) {
            return Disponibilite.fromJson(disponibiliteData);
          }).toList();

          print(disponibilitesList); // For debug
          return disponibilitesList;
        }
      } else {
        print('HTTP Error while fetching disponibilites. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error connecting to the API for disponibilites: $e');
    }

    return null; // Handle errors as you wish
  }



  static Future<bool> deleteUserDocument(String docId) async {
    final token = await getToken();
    if (token == null) {
      print('Error: Token is null');
      return false;
    }

    final response = await http.delete(
      Uri.parse('https://appariteur.com/api/users/document.php?doc_id=$docId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('Document deleted successfully');
        return true;
      } else {
        print('Server responded with error: ${responseData['message']}');
        return false;
      }
    } else {
      print('HTTP Error while deleting document. Status Code: ${response.statusCode}');
      return false;
    }
  }
  static Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      _loggedUserData = null;
      tokenVar = null;
      prefs.clear();
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

}


