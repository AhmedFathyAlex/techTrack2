import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/screens/listscreencentereasytracking.dart';



import 'package:maktrogps/data/screens/notificationscreen.dart';

import 'package:maktrogps/data/screens/settingscreens/settingscreen_2.dart';
import 'package:maktrogps/ui/reusable/global_widget.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_to_speech/text_to_speech.dart';


import '../data/screens/dashboardtrackit.dart';

import '../data/screens/mainmapscreen.dart';
import '../data/screens/settingscreens/settingscreen.dart';
import '../mvvm/view_model/objects.dart';


class BottomNavigation_01 extends StatefulWidget {

  @override
  _BottomNavigation_01State createState() => _BottomNavigation_01State();
}

class _BottomNavigation_01State extends State<BottomNavigation_01> {

  // initialize global widget
  final _globalWidget = GlobalWidget();
  Color _color1 = Color(0xFF0181cc);
  Color _color2 = Color(0xFF515151);
  Color _color3 = Color(0xFFe75f3f);

  late PageController _pageController;
  int _currentIndex = 0;

  // Pages if you click bottom navigation
  final List<Widget> _contentPages = <Widget>[

    Dashboardtrackit(),
    listscreencentereasytracking(),
    mainmapscreen(),
    NotificationsPage(),
    settingscreen_2()

  ];

  bool loaded = false;
  DateTime? currentBackPressTime;
  Timer? _timer;


  @override
  void initState() {

  // PushNotificationService.initialise();
    //initFirebase();

    //TextToSpeech tts = TextToSpeech();

    //tts.speak("Dear Welcome to Tracking Application");
    // set initial pages for navigation to home page
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handleTabSelection);

    super.initState();
    updateToken();
    getObjects();
  }

  void checkPreference() async {
    StaticVarMethod.pref_static = await SharedPreferences.getInstance();
  }

  void getObjects(){
    // Provider.of<ObjectStore>(context, listen: false).getObjectSettings();
    Provider.of<ObjectStore>(context, listen: false).getObjects();
    // Provider.of<EventsStore>(context, listen: false).getEvents("5");
    // Provider.of<DashboardStore>(context, listen: false).getDashboardData();
    // Provider.of<ObjectStore>(context, listen: false).getObjectDriver();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      //  Provider.of<ObjectStore>(context, listen: false).getObjectSettings();
      Provider.of<ObjectStore>(context, listen: false).getObjects();
      // Provider.of<EventsStore>(context, listen: false).getEvents("5");
      // Provider.of<DashboardStore>(context, listen: false).getDashboardData();
    });
    Future.delayed(Duration(seconds: 2)).then((value) => {
      setState(() {
        loaded = true;
      })
    });
  }

  @override
  void dispose() {
    if(_timer != null){
      _timer!.cancel();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
    });
  }

  Future<void> updateToken() async{
    gpsapis.getUserData()
        .then((value) => {gpsapis.activateFCM(StaticVarMethod.notificationToken)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      /*appBar: _globalWidget.globalAppBar(),*/
      // body: PageView(
      //   controller: _pageController,
      //   physics: NeverScrollableScrollPhysics(),
      //   children: _contentPages.map((Widget content) {
      //     return content;
      //   }).toList(),
      // ),
      body:
      WillPopScope(child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _contentPages.map((Widget content) {
          return content;
        }).toList(),
      ), onWillPop: onWillPop),
      extendBody: true,
      bottomNavigationBar: Container(

        /*decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[900]!,
                    width: 1.0,
                  ),
                  top:BorderSide(
                    color: Colors.grey[900]!,
                    width: 1.0,
                  ),
              ),
              ),*/
        //margin: EdgeInsets.only(top: 0, left: 0, right: 0),
        //padding: EdgeInsets.only(left: 0, right: 0),
          child: Card(
            /*shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),

                  ),*/
              elevation: 0,
              shadowColor: Colors.black,
              color: Colors.transparent,
              child: FloatingNavbar(
                /* onTap: (int val) => setState(() => _currentIndex = val),
            currentIndex: _currentIndex,*/
                currentIndex: _currentIndex,
                onTap: (value) {
                  _currentIndex = value;
                  _pageController.jumpToPage(value);
                  // this unfocus is to prevent show keyboard in the text field
                  FocusScope.of(context).unfocus();
                },
                items: [
                  FloatingNavbarItem(icon: Icons.dashboard, title: 'Dash'.tr),

                  FloatingNavbarItem(icon: Icons.list, title: 'List'.tr,),
                  FloatingNavbarItem(icon: Icons.map_outlined, title: 'Map'.tr),


                  FloatingNavbarItem(icon: Icons.notifications_sharp, title: 'Events'.tr),
                  FloatingNavbarItem(icon: Icons.settings, title: 'Setting'.tr),
                ],
                backgroundColor: Colors.grey.shade300,
                selectedItemColor: _color1,
                unselectedItemColor: Colors.black,
                  padding: EdgeInsets.only(bottom: 1, top: 1),
                borderRadius: 10,
                fontSize: 8,
                iconSize: 18,

               // elevation:0,
                // itemBorderRadius: 50,

                //elevation: 2,

              )
          )
      ),

    );
  }


  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;

      showExitPopup();
      // Fluttertoast.showToast(msg: "Are you sure you want to Exit!!! press again");
      // // Navigator.pop(context);
      // // Navigator.pop(context);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> showExitPopup() async{
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to exit?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('yes selected');
                            exit(0);
                            // Navigator.of(context).pop();
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                            // Navigator.pop(context);
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                            // Navigator.of(context).pop();
                          },
                          child: Text("Yes".tr),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red.shade800),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              print('no selected');
                              Navigator.of(context).pop();
                            },
                            child: Text("No".tr, style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

/*
class BottomNavigation extends StatefulWidget {

  final LoginModel loginModel;
  BottomNavigation({Key? key, required this.loginModel}) : super(key: key);
  @override
  _BottomNavigationState createState() => _BottomNavigationState(loginModel:loginModel);
}*/

// class BottomNavigation extends StatefulWidget {
//
//   @override
//   _BottomNavigationState createState() => _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//
//
//   GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
//   // initialize global widget
//   final _globalWidget = GlobalWidget();
//   Color _color1 = Color(0xFF0181cc);
//   Color _color2 = Color(0xFF515151);
//   Color _color3 = Color(0xFFe75f3f);
//
//   late PageController _pageController;
//   int _currentIndex = 0;
//
//   // Pages if you click bottom navigation
//    final List<Widget> _contentPages = <Widget>[
//
//     //listscreen(loginModel : ""),
//      listscreen(),
//      mainmapscreen(),
//      NotificationsPage(),
//      settingscreen(),
//   ];
//
//   @override
//   void initState() {
//     // set initial pages for navigation to home page
//     _pageController = PageController(initialPage: 0);
//     _pageController.addListener(_handleTabSelection);
//
//     /*gpsserverapis.getuserloginapikey();
//     gpsserverapis.login("abc@gmail.com","demo123456");
//     gpsserverapis.getDevicesItems("");*/
//     super.initState();
//     updateToken();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _handleTabSelection() {
//     setState(() {
//     });
//   }
//
//   Future<void> updateToken() async{
//     gpsapis.getUserData()
//         .then((value) => {gpsapis.activateFCM(StaticVarMethod.notificationToken)});
//
//     AudioPlayer player = AudioPlayer();
//     String audioasset = "assets/audio/ignitiononnoti.mp3";
//     ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
//     Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
//     int result = await player.playBytes(soundbytes);
//     if(result == 1){ //play success
//       print("Sound playing successful.");
//     }else{
//       print("Error while playing sound.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.pink.shade100,
//         /*appBar: _globalWidget.globalAppBar(),*/
//         body: PageView(
//           controller: _pageController,
//           physics: NeverScrollableScrollPhysics(),
//           children: _contentPages.map((Widget content) {
//             return content;
//           }).toList(),
//         ),
//           extendBody: true,
//           bottomNavigationBar: CurvedNavigationBar(
//             key: _bottomNavigationKey,
//             index: 0,
//             height: 60.0,
//             items: <Widget>[
//               Icon(Icons.list, size: 30,color: Colors.white,),
//               Icon(Icons.fmd_good_outlined, size: 30,color: Colors.white),
//               Icon(Icons.more, size: 30,color: Colors.white),
//               Icon(Icons.notifications_sharp, size: 30,color: Colors.white),
//              // Icon(Icons.more, size: 30,color: Colors.white),
//             ],
//             color: Colors.blue.shade900,
//
//             //buttonBackgroundColor: Colors.white,
//             backgroundColor: Colors.transparent,
//             //animationCurve: Curves.easeInOut,
//             //animationDuration: Duration(milliseconds: 600),
//             onTap: (index) {
//               setState(() {
//                 setState(() {
//                   _currentIndex = index;
//                   _pageController.jumpToPage(index);
//                   // this unfocus is to prevent show keyboard in the text field
//                   FocusScope.of(context).unfocus();
//                 });
//               });
//             },
//             letIndexChange: (index) => true,
//           ),
//           // Container(
//           //
//           //     /*decoration: BoxDecoration(
//           //       border: Border(
//           //         bottom: BorderSide(
//           //           color: Colors.grey[900]!,
//           //           width: 1.0,
//           //         ),
//           //         top:BorderSide(
//           //           color: Colors.grey[900]!,
//           //           width: 1.0,
//           //         ),
//           //     ),
//           //     ),*/
//           //     //margin: EdgeInsets.only(top: 0, left: 0, right: 0),
//           //     //padding: EdgeInsets.only(left: 0, right: 0),
//           //     child: Card(
//           //         /*shape: RoundedRectangleBorder(
//           //           borderRadius: BorderRadius.circular(10),
//           //
//           //         ),*/
//           //         elevation: 0,
//           //         shadowColor: Colors.black,
//           //         color: Colors.transparent,
//           //         child: FloatingNavbar(
//           //           /* onTap: (int val) => setState(() => _currentIndex = val),
//           //   currentIndex: _currentIndex,*/
//           //           currentIndex: _currentIndex,
//           //           onTap: (value) {
//           //             _currentIndex = value;
//           //             _pageController.jumpToPage(value);
//           //             // this unfocus is to prevent show keyboard in the text field
//           //             FocusScope.of(context).unfocus();
//           //           },
//           //           items: [
//           //             FloatingNavbarItem(icon: Icons.home, title: 'Home'),
//           //             FloatingNavbarItem(icon: Icons.map_outlined, title: 'Map'),
//           //             FloatingNavbarItem(icon: Icons.notifications_sharp, title: 'Events'),
//           //             FloatingNavbarItem(icon: Icons.settings, title: 'Options'),
//           //           ],
//           //           backgroundColor: Colors.grey.shade200,
//           //           selectedItemColor: Colors.black,
//           //           unselectedItemColor: Colors.grey.shade400,
//           //           borderRadius: 20,
//           //           fontSize: 14,
//           //           iconSize: 30,
//           //           elevation:0,
//           //           // itemBorderRadius: 50,
//           //
//           //           //elevation: 2,
//           //
//           //         )
//           //     )
//           // ),
//        /* bottomNavigationBar: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _currentIndex,
//           onTap: (value) {
//             _currentIndex = value;
//             _pageController.jumpToPage(value);
//
//             // this unfocus is to prevent show keyboard in the text field
//             FocusScope.of(context).unfocus();
//           },
//           selectedFontSize: 8,
//           unselectedFontSize: 8,
//           iconSize: 28,
//           items: [
//             BottomNavigationBarItem(
//               // ignore: deprecated_member_use
//                 *//*label:Text('Nav 1', style: TextStyle(
//                     color: _currentIndex == 0 ? _color1 : _color2,
//                     fontWeight: FontWeight.bold
//                 )),*/
//       /*
//                 label:'List',
//                 icon: Icon(
//                     Icons.list,
//                     color: _currentIndex == 0 ? _color1 : _color2
//                 )
//             ),
//             BottomNavigationBarItem(
//               // ignore: deprecated_member_use
//               */
//       /*  title:Text('Nav 2', style: TextStyle(
//                     color: _currentIndex == 1 ? _color3 : _color2,
//                     fontWeight: FontWeight.bold
//                 )),*/
//       /*
//                 label:'Home',
//                 icon: Icon(
//                     Icons.home,
//                     color: _currentIndex == 1 ? _color3 : _color2
//                 )
//             ),
//             BottomNavigationBarItem(
//               // ignore: deprecated_member_use
//                */
//       /* title:Text('Nav 3', style: TextStyle(
//                     color: _currentIndex == 2 ? _color1 : _color2,
//                     fontWeight: FontWeight.bold
//                 )),*/
//       /*
//                 label:'Notifications',
//                 icon: Icon(
//                     Icons.notifications,
//                     color: _currentIndex == 2 ? _color1 : _color2
//                 )
//             ),
//             BottomNavigationBarItem(
//               // ignore: deprecated_member_use
//                 label:'Settings',
//                 icon: Icon(
//                     Icons.person_outline,
//                     color: _currentIndex == 3 ? _color1 : _color2
//                 )
//             ),
//           ],
//         )*/
//     );
//   }
// }
