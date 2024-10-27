import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:maktrogps/bottom_navigation/bottom_navigation_01.dart';
import 'package:maktrogps/config/apps/images.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/loginModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/Services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<SignInScreen> {
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;
  Color mainColor = const Color(0xff0540ac);
  late LoginModel loginModel;
  String _username = "";
   String _password = "";
   String _customserver="";

  //text controlller//
  TextEditingController _usernameFieldController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();
  TextEditingController _customserverFieldController = TextEditingController();
  late SharedPreferences prefs;
  bool isBusy = true;
  bool isLoggedIn = false;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

  int _selectedserver = 0;
  double _dialogHeight = 300.0;
  final _mainColor = const Color(0xff2e414b);
  @override
  void initState() {
    _usernameFieldController.addListener(_emailListen);
    _passwordFieldController.addListener(_passwordListen);
    checkPreference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();


    if (prefs.get('email') != null) {
      _usernameFieldController.text = prefs.getString('email')!;
      _passwordFieldController.text = prefs.getString('password')!;

      _customserverFieldController.text= prefs!.get('baseurlall').toString();
      login();
    } else {
      isBusy = false;
      setState(() {});
    }
  }



  void _emailListen() {
    if (_usernameFieldController.text.isEmpty) {
      _username = "";
    } else {
      _username = _usernameFieldController.text;
    }
  }

  void _passwordListen() {
    if (_passwordFieldController.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFieldController.text;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Platform.isIOS?SystemUiOverlayStyle.light:const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light
          ),
          child: Stack(
            children: <Widget>[
              Container(
                height:MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                   image: DecorationImage(image: AssetImage("assets/images/pakwelcomebackground.png",),
                   fit: BoxFit.cover,opacity: 0.70,)
                ),
              ),
              StatefulBuilder( builder: (BuildContext context, StateSetter setState){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal:30),
                  child: ListView(
                    children: [
                      SizedBox(height:MediaQuery.of(context).size.height*0.10),

                      Container(
                        alignment: Alignment.topCenter,
                        child: Image.asset(height: 100,Images.appBarLogoNew),
                      ),
                      const SizedBox(height: 20,),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 2,
                          child:
                          Container(
                              height: 48,
                              padding: const EdgeInsets.only(left: 20, right: 10),
                              child:
                              TextField(
                                controller: _usernameFieldController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (String value) {
                                  _username = value;
                                },
                                decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.transparent)),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
                                    ),
                                    labelText: 'User ID',
                                    labelStyle: TextStyle(color: Colors.grey[500])),
                              )
                          )
                      ),
                      const SizedBox(height: 10,),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 2,
                          child:
                          Container(
                              height: 48,

                              padding: const EdgeInsets.only(left: 20, right: 10),
                              child:TextField(
                                controller: _passwordFieldController,
                                obscureText: _obscureText,
                                onChanged: (String value) {
                                  _password = value;
                                },
                                decoration: InputDecoration(
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent)),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.grey[500]),
                                  suffixIcon: IconButton(
                                      icon: Icon(_iconVisible, color: Colors.grey[500], size: 20),
                                      onPressed: () {
                                        _toggleObscureText();
                                      }),
                                ),
                              )
                          )
                      ),
                      const SizedBox(height: 20,),
                      SizedBox(
                        height: 48,
                        child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) => _mainColor,
                              ),
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  )
                              ),
                            ),
                            onPressed: () {
                              EasyLoading.show(status: 'loading...');
                              if (_username == null || _username.isEmpty) {

                                Fluttertoast.showToast(msg: 'please provide username !!', toastLength: Toast.LENGTH_SHORT);
                                EasyLoading.dismiss();
                              } else if (_password == null || _password.isEmpty) {
                                Fluttertoast.showToast(msg: 'please provide username !!', toastLength: Toast.LENGTH_SHORT);
                                EasyLoading.dismiss();
                              } else {
                                login();
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login,color: Colors.white,),
                                  SizedBox(width: 15,),
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                        ),
                      ),
                      const SizedBox(height: 30,),
                      // support()
                    ],
                  ),
                );
              }),

            ],
          ),
        )
    );
  }

  Widget support(){

    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Expanded(
          child:  GestureDetector(
            onTap: () {
              launchWhatsApp();
            },
            child: Container(

                child:   Column(
                    children: <Widget>[
                      Image.asset("assets/speedoicon/assets_images_whatsappicon.png", height: 30,width: 30),
                      const Text('  Support  ',  style: TextStyle(
                          fontSize: 12,height: 2.0,fontWeight: FontWeight.bold,color: Colors.white))
                    ]
                )
            ),
          ),
        ),
        Expanded(
          child:  GestureDetector(
            onTap: () {
              _username="demo@gmail.com";
              _password="123456";
              login();


            },
            child: Container(

                child:   Column(
                    children: <Widget>[

                      const SizedBox(height: 0,),
                      Image.asset("assets/speedoicon/assets_images_vehicleicon.png", height: 30,width: 30),
                      const Text('  Demo  ',  style: TextStyle(
                          fontSize: 12,height: 2.0,fontWeight: FontWeight.bold,color: Colors.white))
                    ]
                )
            ),
          ),
        ),
        Expanded(
          child:  GestureDetector(
            onTap: () {
              showserverDialog(context);
            },
            child: Container(

                child:   Column(
                    children: <Widget>[
                      Image.asset("assets/images/switchserver.png", height: 30,width: 30),
                      const Text('  Switch Server  ',  style: TextStyle(
                          fontSize: 13,height: 2.0,fontWeight: FontWeight.bold,color: Colors.lightBlueAccent))
                    ]
                )
            ),
          ),
        ),
      ],
    );
  }

  

  launchWhatsApp() async {
    final link = const WhatsAppUnilink(

      phoneNumber: '03000835556',


      text: "Hey! I'm inquiring about the Tracking listing",
    );
    await launch('$link');
  }

  Future<void> login() async{
    gpsapis api=new gpsapis();
    api.getlogin(_username, _password).then((response) {

      if (response != null) {
        if (response.statusCode == 200) {
          prefs.setBool("popup_notify", true);
          prefs.setString("user", response.body);
          isBusy = false;
          isLoggedIn = true;
          final res= LoginModel.fromJson(json.decode(response.body));
          StaticVarMethod.user_api_hash=res.userApiHash;
          EasyLoading.dismiss();
          prefs.setString('user_api_hash', res.userApiHash!);


          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigation_01()),

          );
        } else if (response.statusCode == 401) {
          isBusy = false;
          isLoggedIn = false;
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: "Login Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {});
        } else if (response.statusCode == 400) {
          isBusy = false;
          isLoggedIn = false;
          if (response.body ==
              "Account has expired - SecurityException (PermissionsManager:259 < *:441 < SessionResource:104 < ...)") {
            setState(() {});
            showDialog(
              context: context,
              builder: (context) =>  AlertDialog(
                title: const Text("Failed"),
                content: const Text(
                    "Login Failed"),
                actions: <Widget>[
                   ElevatedButton(
                    onPressed: () {
                      EasyLoading.dismiss();
                      Navigator.of(context, rootNavigator: true)
                          .pop(); // dismisses only the dialog and returns nothing
                    },
                    child:  const Text(
                        "ok"),
                  ),
                ],
              ),
            );
          }
        } else {
          isBusy = false;
          isLoggedIn = false;
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: response.body,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {});
        }
      } else {
        isLoggedIn = false;
        isBusy = false;
        setState(() {});
        EasyLoading.dismiss();
        Fluttertoast.showToast(
            msg: "Error Msg",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.lightGreen.shade50,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
 void showserverDialog(BuildContext context) {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return  Container(
            height: _dialogHeight,
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          
                           Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                               Radio(
                                value: 3,
                                groupValue: _selectedserver,
                                onChanged: (value) {
                                  setState(() {
                                    _dialogHeight = 400.0;
                                    _selectedserver = value!;
                                  });
                                },
                              ),
                               const Text('Custom Server',
                                style:  TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                          _selectedserver == 3
                              ?  Container(

                              padding: const EdgeInsets.all(20),
                              child:  Column(
                                children: <Widget>[


                                  TextField(
                                    controller: _customserverFieldController,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (String value) {
                                      _customserver = value;
                                    },
                                    decoration: InputDecoration(
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey)),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                        ),
                                        labelText: 'Custom Server',
                                        labelStyle: TextStyle(color: Colors.grey[500])),
                                  )


                                ],
                              ))
                              :  Container(),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red, // background
                                  backgroundColor: Colors.white, // foreground
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showReport();
                                },
                                child: const Text('Save',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }


  Future<void> showReport() async {
    if (_selectedserver == 0) {
      await prefs!.setString('baseurlall', "https://track.impressivebd.com");
      StaticVarMethod.baseurlall="https://track.impressivebd.com";
      _customserverFieldController.text= StaticVarMethod.baseurlall;
      Navigator.pop(context);
    } else if (_selectedserver == 1) {
      await prefs!.setString('baseurlall', "https://track.safetyvts.com");
      StaticVarMethod.baseurlall="https://track.safetyvts.com";
      _customserverFieldController.text= StaticVarMethod.baseurlall;
      Navigator.pop(context);
    } else if (_selectedserver == 2) {
      await prefs!.setString('baseurlall', "http://brtcvts.com");
      StaticVarMethod.baseurlall= "http://brtcvts.com";
      _customserverFieldController.text= StaticVarMethod.baseurlall;
      Navigator.pop(context);
    }else if (_selectedserver == 3) {
      await prefs!.setString('baseurlall', _customserver);
      StaticVarMethod.baseurlall=_customserver;
      _customserverFieldController.text= StaticVarMethod.baseurlall;
      Navigator.pop(context);
    }

    setState(() {
    });
  }

}
