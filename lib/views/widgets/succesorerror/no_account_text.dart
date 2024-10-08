import 'package:flutter/material.dart';
import '../addonglobal/size_config.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          " Vous n'avez pas de compte ? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(16)),
        ),
        GestureDetector(
          //onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignUpScreen()), ),
          child: Text(
            "S'inscrire",
            style: TextStyle(
                fontSize: getProportionateScreenWidth(16), color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
