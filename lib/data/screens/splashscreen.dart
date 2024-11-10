import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:maktrogps/bottom_navigation/bottom_navigation_01.dart';
import 'package:maktrogps/config/apps/images.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../model/loginModel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    checkPreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Container(
                  child: Image.asset(Images.splashImageNew),
                ),
      ),
    );
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
   
    if (prefs!.get('email') != null) {
      if (prefs!.get("popup_notify") == null) {
        prefs!.setBool("popup_notify", true);
      }
      checkLogin();
    } else {
      prefs!.setBool("popup_notify", true);
     await Future.delayed(Duration(milliseconds:1000 ));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignInScreen()
        ),
      );
    }
  }

  void checkLogin() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      gpsapis api=new gpsapis();

      api.getlogin(prefs!.get('email').toString(), prefs!.get('password').toString()).then((response) {

        if (response != null) {
          if (response.statusCode == 200) {
            prefs!.setBool("popup_notify", true);
            prefs!.setString("user", response.body);
            final res= LoginModel.fromJson(json.decode(response.body));
            StaticVarMethod.user_api_hash=res.userApiHash;
            prefs!.setString('user_api_hash', res.userApiHash!);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomNavigation_01()),

            );
          } else {

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignInScreen()
              ),

            );
          }
        } else {

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignInScreen()
            ),

          );

        }
      });
    });
  }

}
