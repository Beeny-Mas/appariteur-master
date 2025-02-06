import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/apihelper.dart';
import '../../helper/routes/routes.dart';
import '../../views/widgets/InputDecoration.dart';
import '../../views/widgets/images.dart';
import '../loginController/childlogin.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    var email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer votre email')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await AuthApi.resetPassword(email);
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Réinitialisation du mot de passe'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Nous vous avons envoyé un e-mail contenant un lien de réinitialisation de votre mot de passe.'),
                    Text('Cliquez sur ce lien pour récupérer votre compte sur appariteur.com !'),
                    Text('Si vous n\'avez pas reçu le mail sous  10 minutes, vérifiez vos courriers indésirables.'),
                    Text('Merci !!!'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réinitialisation du mot de passe')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réinitialisation du mot de passe: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
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
        child: Column(
          children: <Widget>[
            SizedBox(height:  100),
            Text(
              "Réinitialiser le mot de passe",
              style: GoogleFonts.montserrat(
                textStyle: boldTextStyle(size: 24, color: Colors.white),
              ),
            ),
            SizedBox(height: 25),
            SingleChildScrollView(
              child: Container(
                width:  400, // Largeur fixe pour le contenu scrollable
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left:  16, right:  16, bottom:  16),
                          margin: EdgeInsets.only(top:  55.0),
                          decoration: boxDecorationWithShadow(
                            borderRadius: BorderRadius.circular(30),
                            backgroundColor: context.cardColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height:  80), // Pour l'espacement sous le logo
                              AppTextField(
                                decoration: coInputDecoration(
                                  hint: 'Entrer votre email',
                                  context: context,
                                  prefixIcon: Icons.email_outlined,
                                ),
                                textFieldType: TextFieldType.EMAIL,
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                focus: emailFocusNode,
                              ),
                              30.height,
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : AppButton(
                                text: "Réinitialiser le mot de passe",
                                color: Colors.blue,
                                textColor: Colors.white,
                                shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: _w,
                                onTap: _resetPassword,
                              ).paddingOnly(
                                left: _w *  0.1,
                                right: _w *  0.1,
                              ),
                              30.height,
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height:  100,
                          width:  100,
                          decoration: boxDecorationRoundedWithShadow(30, backgroundColor: context.cardColor),
                          child: Image.asset(
                            Images.logo,
                            height:  50,
                            width:  80,
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
    );
  }
}
