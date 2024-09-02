import 'dart:convert';

import 'package:appariteur/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../models/user.dart';
import '../../views/notif/notifScreen.dart';
import '../../views/widgets/InputDecoration.dart';
import '../../views/widgets/addonglobal/bottombar.dart';
import '../../views/widgets/images.dart';
import '../loginController/childlogin.dart';
import 'package:http/http.dart' as http;
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var phoneController = TextEditingController();
  var birthdateController = TextEditingController();
  var birthplaceController = TextEditingController();
  var streetController = TextEditingController();
  var cityController = TextEditingController();
  var countryController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode birthdateFocusNode = FocusNode();
  FocusNode birthplaceFocusNode = FocusNode();
  FocusNode streetFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  bool isLoading = false;

  String selectedGender = "";

  Future<void> signUpUser() async {
    setState(() {
      isLoading = true;
    });

    // Vérification des champs obligatoires
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }


    final phonePattern = RegExp(r'^\+33[0-9]{9}$');
    if (phoneController.text.isNotEmpty && !phonePattern.hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro de téléphone invalide'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }


    // Vérification de la correspondance des mots de passe
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Vérification du format de l'adresse e-mail
    final emailPattern = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailPattern.hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adresse e-mail invalide'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Assignation de valeurs par défaut pour les champs non obligatoires
    String gender = selectedGender.isNotEmpty ? selectedGender : "";
    String birthdate = birthdateController.text.isNotEmpty ? birthdateController.text : "";
    String fullAddress = streetController.text.isNotEmpty ? "${streetController.text}, ${cityController.text}, ${countryController.text}" : "";

    try {
      final response = await http.post(
        Uri.parse('https://appariteur.com/api/users/register.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(UserData(
          name: nameController.text,
          email: emailController.text,
          tel: phoneController.text,
          sexe: gender,
          password: passwordController.text,
          datenais: birthdate,
          lieunais: birthplaceController.text,
          rue: fullAddress,
          pays: countryController.text.isNotEmpty ? countryController.text : "",
        ).toApiJson()),
      );

      if (response.statusCode == 201) {
        print("Succès");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Succès'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Inscription réussie! Vous pouvez maintenant vous connecter'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Erreur lors de l\'inscription: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Exception lors de l\'inscription: $e');
      print('StackTrace: $stackTrace');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    countryFocusNode.unfocus();
    phoneController.text = "";
    phoneController.addListener(() {
      if (phoneController.text.length > 12) {
        phoneController.text = phoneController.text.substring(0, 12);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    countryController.text = "France";
    countryController..text = "France";

    return Scaffold(
      body: Container(
        width: _w,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg appariteur app.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              Text(
                "S'inscrire",
                style: GoogleFonts.montserrat(
                  textStyle: boldTextStyle(size: 24, color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              SingleChildScrollView(
                child: Container(
                  width: 1200, // Largeur fixe pour le contenu scrollable
                  child: Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            margin: EdgeInsets.only(top: 55.0),
                            decoration: boxDecorationWithShadow(
                              borderRadius: BorderRadius.circular(30),
                              backgroundColor: context.cardColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 60),
                                Row(children: [Text("*", style: TextStyle(color: Colors.red),),Text(" Indique un champ obligatoire")],),
                                SizedBox(height: 15),
                                AppTextField(
                                  decoration: coInputDecoration(
                                    hint: 'Entrer vos noms et prénoms',
                                    context: context,
                                    prefixIcon: Icons.person_outline,
                                    borderColor: Colors.blue,

                                  ),
                                  textFieldType: TextFieldType.NAME,
                                  keyboardType: TextInputType.text,
                                  controller: nameController,
                                  focus: nameFocusNode,
                                  nextFocus: emailFocusNode,
                                  cursorColor: Colors.blue,
                                  suffix: Text("*", style: TextStyle(color: Colors.red, fontWeight:FontWeight.bold ),)


                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre adresse mail',
                                      context: context,
                                      prefixIcon: Icons.mail_outline,
                                      borderColor: Colors.blue
                                  ),

                                  textFieldType: TextFieldType.EMAIL,
                                  keyboardType: TextInputType.text,
                                  controller: emailController,
                                  focus: emailFocusNode, suffix: Text("*", style: TextStyle(color: Colors.red, fontWeight:FontWeight.bold ),),
                                  nextFocus: phoneFocusNode,

                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                    hint: 'Entrer votre numéro de téléphone',
                                    context: context,
                                    prefixIcon: Icons.phone_outlined,
                                  ),
                                  textFieldType: TextFieldType.NUMBER,
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                  focus: phoneFocusNode,
                                  cursorColor: Colors.blue,
                                ),
                                16.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sexe',
                                      style: primaryTextStyle(),
                                    ).paddingOnly(right: 16),
                                    Row(
                                      children: [
                                        Radio(
                                          activeColor: Colors.blue,
                                          value: 'Masculin',
                                          groupValue: selectedGender,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGender = value.toString();
                                            });
                                          },
                                        ),
                                        Text('Masculin', style: primaryTextStyle()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          activeColor: Colors.blue,
                                          value: 'Féminin',
                                          groupValue: selectedGender,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGender = value.toString();
                                            });
                                          },
                                        ),
                                        Text('Féminin', style: primaryTextStyle()),
                                      ],
                                    ),
                                  ],
                                ),
                                16.height,
                                // Ajoutez ici les autres champs de texte pour les informations requises
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre mot de passe',
                                      context: context,
                                      prefixIcon: Icons.lock_clock_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.PASSWORD,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordController,
                                  focus: passwordFocusNode,
                                  nextFocus: birthdateFocusNode,
                                  cursorColor: Colors.blue,
                                    suffix: Text("*", style: TextStyle(color: Colors.red, fontWeight:FontWeight.bold ),)
                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Confirmation de votre mot de passe',
                                      context: context,
                                      prefixIcon: Icons.lock_clock_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.PASSWORD,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: confirmPasswordController,
                                  focus: confirmPasswordFocusNode,
                                  nextFocus: passwordFocusNode,
                                  cursorColor: Colors.blue,
                                    suffix: Text("*", style: TextStyle(color: Colors.red, fontWeight:FontWeight.bold ),)
                                ),
                                16.height,
                                GestureDetector(
                                  onTap: () async {
                                    DateTime? selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );

                                    if (selectedDate != null && selectedDate != DateTime.now()) {
                                      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                      birthdateController.text = formattedDate;
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: AppTextField(
                                      decoration: coInputDecoration(
                                          hint: 'Choisir la date de naissance',
                                          context: context,
                                          prefixIcon: Icons.calendar_today,
                                          borderColor: Colors.blue
                                      ),
                                      keyboardType: TextInputType.text,
                                      controller: birthdateController,
                                      focus: birthdateFocusNode,
                                      nextFocus: birthplaceFocusNode,
                                      textFieldType: TextFieldType.OTHER,
                                      cursorColor: Colors.blue,
                                    ),
                                  ),
                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre lieu de naissance',
                                      context: context,
                                      prefixIcon: Icons.place_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.NAME,
                                  keyboardType: TextInputType.text,
                                  controller: birthplaceController,
                                  focus: birthplaceFocusNode,
                                  nextFocus: streetFocusNode,
                                  cursorColor: Colors.blue,
                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre rue',
                                      context: context,
                                      prefixIcon: Icons.streetview_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.NAME,
                                  keyboardType: TextInputType.text,
                                  controller: streetController,
                                  focus: streetFocusNode,
                                  nextFocus: cityFocusNode,
                                  cursorColor: Colors.blue,
                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre ville de résidence',
                                      context: context,
                                      prefixIcon: Icons.location_city_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.NAME,
                                  keyboardType: TextInputType.text,
                                  controller: cityController,
                                  focus: cityFocusNode,
                                  nextFocus: countryFocusNode,
                                  cursorColor: Colors.blue,
                                ),
                                16.height,
                                AppTextField(
                                  decoration: coInputDecoration(
                                      hint: 'Entrer votre pays de résidence',
                                      context: context,
                                      prefixIcon: Icons.place_outlined,
                                      borderColor: Colors.blue
                                  ),
                                  textFieldType: TextFieldType.NAME,
                                  keyboardType: TextInputType.text,
                                  controller: countryController,
                                  focus: countryFocusNode,
                                  cursorColor: Colors.blue,
                                ),
                                16.height,
                                30.height,
                                isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    :AppButton(
                                  text: "S'inscrire",
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  width: _w,
                                  onTap: () {
                                    print("Button tapped");  // Add this line for debugging
                                    signUpUser();


                                  },
                                ).paddingOnly(
                                  left: _w * 0.1,
                                  right: _w * 0.1,
                                ),

                                30.height,
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 100,
                            width: 100,
                            decoration: boxDecorationRoundedWithShadow(30, backgroundColor: context.cardColor),
                            child: Image.asset(
                              Images.logo,
                              height: 50,
                              width: 80,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ],
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
