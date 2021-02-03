import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isSignedIn = false;

  buildHomeScreen() => Text('already signeind in');

  Scaffold buildSignInScreen() => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Theme.of(context).accentColor,Theme.of(context).primaryColor]
            )
          ),
          alignment: Alignment.center,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Instagram',
                style: TextStyle(
                    fontSize: 92.0,
                    color: Colors.white,
                    fontFamily: 'Signatra'),
              ),
              GestureDetector(
                onTap: () => "ButtonTap",
                child: Container(
                  width: 270.0,
                  height: 65.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/google_signin_button.png"))),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
