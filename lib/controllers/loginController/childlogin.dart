import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/apihelper.dart';
import '../../helper/routes/routes.dart';
import '../../views/notif/notifScreen.dart';
import '../../views/widgets/InputDecoration.dart';
import '../../views/widgets/addonglobal/bottombar.dart';
import '../../views/widgets/images.dart';
import '../passwordresetController/passwordreset.dart';
import '../registerController/childRegister.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();
  bool isLoading = false;

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.appariteur.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de lancer $url')),
      );
    }
  }

  Future<void> _login() async {
    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var userData = await AuthApi.login(email, password);
      if (userData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyBottomNav()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Identifiants incorrects ou problème de connexion')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion: ${e.toString()}')),
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
            SizedBox(height: 100),
            Text("Se connecter", style: boldTextStyle(size: 24, color: black)),
            SingleChildScrollView(
              child: Container(
                width: 400, // Largeur fixe pour le contenu scrollable
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
                              SizedBox(height: 80), // Pour l'espacement sous le logo
                              AppTextField(
                                decoration: coInputDecoration(
                                  hint: 'Entrer votre email',
                                  context: context,
                                  prefixIcon: Icons.email_outlined,
                                  borderColor: Colors.blue
                                ),
                                textFieldType: TextFieldType.EMAIL,
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                focus: emailFocusNode,
                                nextFocus: passWordFocusNode,
                                cursorColor: Colors.blue,
                              ),
                              16.height,
                              AppTextField(
                                decoration: coInputDecoration(
                                  borderColor: Colors.blue,
                                  context: context,
                                  hint: 'Entrer votre mot de passe',
                                  prefixIcon: Icons.lock_outline,
                                ),
                                suffixIconColor: Colors.blue,
                                cursorColor: Colors.blue,
                                textFieldType: TextFieldType.PASSWORD,
                                isPassword: true,
                                keyboardType: TextInputType.visiblePassword,
                                controller: passwordController,
                                focus: passWordFocusNode,
                              ),
                              5.height,
                              Align(
                                alignment: Alignment.centerRight,
                                child:
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              10.height,
                              isLoading
                                  ? Center(child: CircularProgressIndicator(color: Colors.blue,))
                                  : AppButton(
                                text: "Se connecter",
                                color: Colors.blue,
                                textColor: Colors.white,
                                shapeBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                width: _w,
                                onTap: _login,
                              ).paddingOnly(
                                left: _w * 0.1,
                                right: _w * 0.1,
                              ),
                              30.height,
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Vous n\'avez pas de compte?',
                                      style: primaryTextStyle(
                                          color: Colors.grey)),
                                  3.width,
                                  Flexible(
                                    child: Text('Inscrivez-vous ici',
                                        textAlign: TextAlign.center,
                                        style: boldTextStyle(color: black)),
                                  ),
                                ],
                              ).onTap(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()
                                  ),
                                );
                              }).center(),
                              20.height,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16), // Réduit le padding bottom
                child: TextButton(
                  onPressed: _launchURL,
                  child: Text(
                    "Découvrir Appariteur",
                    style: GoogleFonts.merienda(
                      fontSize: _w * 0.05,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
