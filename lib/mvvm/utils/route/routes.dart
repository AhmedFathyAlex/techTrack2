

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maktrogps/data/screens/sign_in_screen.dart';
import 'package:maktrogps/mvvm/utils/route/routes_name.dart';



class Routes{
  
  static Route<dynamic>  generateRoute(RouteSettings settings){
    switch(settings.name){
      case RouteName.login:
        return MaterialPageRoute(
    builder: (context) => SignInScreen()
        );
      default:
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            body: Center(child: Text("No route Defined"),),
        );
        });
    }
  }
}