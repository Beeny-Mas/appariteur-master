import 'package:appariteur/controllers/profile/profileimg.dart';
import 'package:appariteur/controllers/profile/profileimgedit.dart';
import 'package:appariteur/views/widgets/addonglobal/topbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../data/apihelper.dart';
import 'editprofile.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserData? userData;
  bool isEditing = false;


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController lieuxPlaceController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  Future<void> getUserData() async {


      userData = await AuthApi.getOnlineUserData();
    }


  @override
  void initState() {
    super.initState();

  }
  void _showEditConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier le profil"),
          content: Text("Si vous concluez votre processus de modification, vous serez déconnecté et devrez vous reconnecter. "
              "Voulez-vous continuer?"),
          actions: <Widget>[
           TextButton(
              child: Text("Non"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text("Oui"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePageEdit(), // Navigue vers ProfilePageEdit
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;
    Future<void> ShowUserData() async {
      final user = await AuthApi. getLocalUserData();
      if (user != null) {
        nameController.text = user.name!;
        emailController.text = user.email!;
        genderController.text = user.sexe!;
        phoneNumberController.text = user.tel!;
        birthDateController.text = user.datenais!;
        lieuxPlaceController.text = user.lieunais!;
        addressController.text = user.rue!;
        postalCodeController.text = user.codepostal!;
        countryController.text = user.pays!;
      } else {

      }
    }

    ShowUserData();
    return Scaffold(
      appBar: TopBarS(onNotificationPressed: (){}, PageName: "Mon compte", showBackButton: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_w / 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: _h * 0.01),
              const ProfileImg(),
              SizedBox(height: _h * 0.01),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nom",
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: genderController,
                        decoration: const InputDecoration(
                          labelText: 'Sexe',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: lieuxPlaceController,
                        decoration: const InputDecoration(
                          labelText: 'Lieux de naissance',
                        ),
                        readOnly: !isEditing,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Mail',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Code postal',
                        ),
                        readOnly: !isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: countryController,
                        decoration: const InputDecoration(
                          labelText: 'Pays',
                        ),
                        readOnly: !isEditing,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:_showEditConfirmationDialog,

                    child: Text( 'Modifier'),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}