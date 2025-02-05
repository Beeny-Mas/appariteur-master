import 'dart:async';
import 'dart:io';
import 'package:appariteur/controllers/loginController/childlogin.dart';
import 'package:appariteur/views/widgets/addonglobal/topbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/apihelper.dart';
import '../../models/user.dart';

class ProfilePageEdit extends StatefulWidget {
  final UserData? userData;

  const ProfilePageEdit({Key? key, this.userData}) : super(key: key);

  @override
  _ProfilePageEditState createState() => _ProfilePageEditState();
}

class _ProfilePageEditState extends State<ProfilePageEdit> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _sexeController = TextEditingController();
  late TextEditingController _telController = TextEditingController();
  late TextEditingController _datenaisController = TextEditingController();
  late TextEditingController _lieunaisController = TextEditingController();
  late TextEditingController _adresseController = TextEditingController();
  late TextEditingController _codepostalController = TextEditingController();
  late TextEditingController _paysController = TextEditingController();

  UserData? userData;

  Future<void> getUserData() async {
    try {
      UserData? fetchedUserData = await AuthApi.getLocalUserData();
      if (fetchedUserData == null || fetchedUserData.userId == null || fetchedUserData.appariteurId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Echec de récupération des données utilisateur')));
        return;
      }
      setState(() {
        userData = fetchedUserData;
        _initializeControllers(fetchedUserData);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Echec de récupération des données utilisateur')));
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void _initializeControllers(UserData fetchedUserData) {
    _nameController.text = fetchedUserData.name ?? '';
    _emailController.text = fetchedUserData.email ?? '';
    _sexeController.text = fetchedUserData.sexe ?? '';
    _telController.text = fetchedUserData.tel ?? '';
    _datenaisController.text = fetchedUserData.datenais ?? '';
    _lieunaisController.text = fetchedUserData.lieunais ?? '';
    _adresseController.text = fetchedUserData.adresse ?? '';
    _codepostalController.text = fetchedUserData.codepostal ?? '';
    _paysController.text = fetchedUserData.pays ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Echec de récupération des données utilisateur')));
      return;
    }

    UserData updatedUserData = UserData(
      userId: userData!.userId,
      appariteurId: userData!.appariteurId,
      name: _nameController.text,
      email: _emailController.text,
      sexe: _sexeController.text,
      tel: _telController.text,
      datenais: _datenaisController.text,
      lieunais: _lieunaisController.text,
      adresse: _adresseController.text,
      codepostal: _codepostalController.text,
      pays: _paysController.text,
    );

    print('UpdatedUserData: ${updatedUserData.toJson()}');
    bool? success = await AuthApi.updateProfile(updatedUserData, _imageFile);
    if (success == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 24),
                  Text("Modification effectuée."),
                ],
              ),
            ),
          );
        },
      );

      Timer(Duration(seconds: 3), () async {
        Navigator.pop(context); // Close the dialog
        await AuthApi.logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 24),
                  Text("Modification effectuée."),
                ],
              ),
            ),
          );
        },
      );

      Timer(Duration(seconds: 3), () async {
        Navigator.pop(context); // Close the dialog
        await AuthApi.logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarS(onNotificationPressed: (){}, PageName: "Modifier le profil",showBackButton: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                ),
              ),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: _sexeController, decoration: const InputDecoration(labelText: "Sexe")),
              TextField(controller: _telController, decoration: const InputDecoration(labelText: "Téléphone"), keyboardType: TextInputType.phone),
              TextField(
                controller: _datenaisController,
                decoration: const InputDecoration(labelText: "Date de naissance"),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _datenaisController.text = formattedDate;
                    });
                  }
                },
              ),
              TextField(controller: _adresseController, decoration: const InputDecoration(labelText: "Adresse")),
              TextField(controller: _lieunaisController, decoration: const InputDecoration(labelText: "Lieu de naissance")),
              TextField(controller: _codepostalController, decoration: const InputDecoration(labelText: "Code Postal"), keyboardType: TextInputType.number),
              TextField(controller: _paysController, decoration: const InputDecoration(labelText: "Pays")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _updateProfile, child: const Text('Enregistrer')),
            ],
          ),
        ),
      ),
    );
  }
}
