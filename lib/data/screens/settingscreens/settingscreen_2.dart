

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:maktrogps/bottom_navigation/bottom_navigation_01.dart';

import 'package:maktrogps/config/apps/ecommerce/constant.dart';
import 'package:maktrogps/config/apps/food_delivery/global_style.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/User.dart';
import 'package:maktrogps/data/screens/alerts/AlertList.dart';
import 'package:maktrogps/data/screens/livetrackoriginal.dart';
import 'package:maktrogps/data/screens/playback.dart';
import 'package:maktrogps/data/screens/playbackselection.dart';
import 'package:maktrogps/data/screens/registerscreen.dart';
import 'package:maktrogps/data/screens/settingscreens/changedevicesettings.dart';
import 'package:maktrogps/data/screens/settingscreens/privacypolicy.dart';
import 'package:maktrogps/data/screens/reports/kmdetail.dart';
import 'package:maktrogps/data/screens/reports/reportselection.dart';

import 'package:maktrogps/data/screens/sign_in_screen.dart';

import 'package:maktrogps/data/screens/supportscreen.dart';
import 'package:maktrogps/data/screens/settingscreens/termsandconditions.dart';
import 'package:maktrogps/ui/reusable/cache_image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../AlertList.dart';
import '../addalert.dart';
import '../browser_module_old/browser.dart';
import '../geofences/GeofenceList.dart';


class settingscreen_2 extends StatefulWidget {
  @override
  _settingscreenState createState() => _settingscreenState();
}

class _settingscreenState extends State<settingscreen_2> {
  // initialize reusable widget
  // final _reusableWidget = ReusableWidget();
  late User user;
  late SharedPreferences prefs;
  bool isLoading = true;
  final TextEditingController _newPassword = new TextEditingController();
  final TextEditingController _retypePassword = new TextEditingController();
  bool _val = true;
   String email ="";
   String expiration_date ="";
  @override
  void initState() {
    getUser();
    checkPreference();
    super.initState();
  }
  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    _val= prefs.getBool("notival")!;

  }

  getUser() async {
    gpsapis.getUserData().then((value) => {
      isLoading = false,
      user = value!,
      email = value!.email.toString(),
      expiration_date = value.expiration_date.toString(),
      setState(() {})
    });
    setState(() {});
  }


  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey[300],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
       /* iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),*/
        //systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: true,
        title: Text('Settings Screen'.tr, style: GlobalStyle.appBarTitle),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [

           _createAccountInformation(),
          //_buildmoreswitch(),
         _buildmoreManues(),
          //_buildmoreManues2(),
         // _buildmoreManues3(),
          _buildsettings(),
          _buildManues(),
        ],
      ),

    );
  }

  Widget _createAccountInformation(){
    final double profilePictureSize = MediaQuery.of(context).size.width/4;
    return Container(
      margin: EdgeInsets.all(5),
    child: Card(
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
   //elevation: 2,
    color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: profilePictureSize,
            height: profilePictureSize,
            padding: EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(msg: 'Click picture', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: profilePictureSize,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: profilePictureSize-4,
                      child: Hero(
                        tag: 'profilePicture',
                        child: ClipOval(
                          child:Image.asset("assets/images/icons8-traffic-jam-100.png", height: profilePictureSize-4,width: profilePictureSize-4),

                          //child: buildCacheNetworkImage(width: profilePictureSize-4, height: profilePictureSize-4, url: GLOBAL_URL+'/assets/images/user/avatar.png')
                        ),
                      ),
                    ),
                  ),
                ),

          ),
          SizedBox(
            width: 16,
          ),
          (email.isNotEmpty)?
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(''+email, style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold
                )),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                  onTap: (){
                    Fluttertoast.showToast(msg: 'Click account information / user profile', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Row(
                    children: [
                     /* Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                    ],
                  ),
                )
              ],
            ),
          ) :CircularProgressIndicator(),
        ],
      ),
    )
    );
  }

  Widget _buildmoreswitch(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => playbackselection()),
                      // );
                    },
                    child: Container(
                        padding: EdgeInsets.all(1),

                        /*decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),*/
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Image.asset("assets/images/moreicon.png", height: 35,width: 35),
                              Text('More'.tr,  style: TextStyle(
                                  fontSize: 18,height: 1.5,fontWeight: FontWeight.bold)),


                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
  Widget _buildsettings(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => playbackselection()),
                      // );
                    },
                    child: Container(
                        padding: EdgeInsets.all(1),

                        /*decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),*/
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Image.asset("assets/images/settingicon.png", height: 35,width: 35),
                              Text('Settings'.tr,  style: TextStyle(
                                  fontSize: 18,height: 1.5,fontWeight: FontWeight.bold)),


                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildmoreManues(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Expanded(
            //   child: Column(
            //     children: <Widget>[
            //       GestureDetector(
            //         onTap: () async {
            //           //final url ="https://www.maktro.com/mgt/pay/";
            //        //   final url ="https://expresstraqr.in/contact.html";
            //           final url ="";
            //           _launchURL(url);
            //          // _launchURL("https://mototrackerbd.com/dashboard/customer_bill_pay");
            //         },
            //         child: Container(
            //             padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),
            //
            //             decoration: new BoxDecoration(
            //               color: Colors.white,
            //               shape: BoxShape.rectangle,
            //               borderRadius:BorderRadius.all(Radius.circular(15)),
            //               // borderRadius: BorderRadius.circular(8),
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.black26,
            //                   blurRadius: 10.0,
            //                   //offset: const Offset(0.0, 10.0),
            //                 ),
            //               ],
            //             ),
            //             // color: Colors.white,
            //             //color: Color(0x99FFFFFF),
            //             child:   Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: <Widget>[
            //                   Text('PayNow'.tr,  style: TextStyle(
            //                       fontSize: 16, color: SOFT_GREY)),
            //                   Image.asset("assets/settingicon/payment.png", height: 40,width: 40),
            //
            //                 ]
            //             )
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(width: 25),


            /*Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => supportscreen()),
                      );

                      //_launchURL("https://safetygpstracker.com.bd/");

                      // _launchURL("https://m.me/+923414910057?ref=bb54fea9559f614364722d530070222f3980223b84f769ff1");
                      // launchWhatsApp();
                      //  _launchURL("https://m.me/253098044733617?ref=bb54fea9559f614364722d530070222f3980223b84f769ff1");
                    },
                    child: Container(
                        padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Support'.tr,  style: TextStyle(
                                  fontSize: 16, color: SOFT_GREY)),
                              Image.asset("assets/settingicon/livesupport.png", height: 40,width: 40),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),*/

          ],
        )
    );
  }

  Widget _buildmoreManues2(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // _launchURL("https://safetygpstracker.com.bd/price_list");
                      // _launchURL("http://mototrackerbd.com/");
                      //final url ="https://safetygpstracker.com.bd/price_list";
                      //final url ="http://mototrackerbd.com/";
                      final url ="";

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Browser(
                                dashboardName: "Pricing",
                                dashboardURL: url,
                              )));
                    },
                    child: Container(
                        padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Pricing',  style: TextStyle(
                                  fontSize: 16, color: SOFT_GREY)),
                              Image.asset("assets/settingicon/pricing.png", height: 40,width: 40),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      //_launchURL("https://safetygpstracker.com.bd/single_page/1");
                      //_launchURL("http://trackcaronline/");
                      //_launchURL("http://mototrackerbd.com/");

                     // final url ="https://safetygpstracker.com.bd/single_page/1";
                     // final url ="http://mototrackerbd.com/";
                     // final url ="https://www.maktro.com/mgt/pay/";
                      //final url ="https://expresstraqr.in/contact.html";
                      final url ="";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Browser(
                                dashboardName: "About US",
                                dashboardURL: url,
                              )));
                    },
                    child: Container(
                        padding: EdgeInsets.only(top:15,bottom: 15,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('About Us',  style: TextStyle(
                                  fontSize: 16, color: SOFT_GREY)),
                              Image.asset("assets/settingicon/aboutus.png", height: 40,width: 40),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildmoreManues3(){
    return Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container(
                        padding: EdgeInsets.only(top:18,bottom: 18,left: 10, right: 5),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Share Location',  style: TextStyle(
                                  fontSize: 15, color: SOFT_GREY)),
                              Image.asset("assets/settingicon/sharelocation.png", height: 30,width: 30),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {

                     // _launchURL("https://safetygpstracker.com.bd/vms");

                     // _launchURL("http://mototrackerbd.com/vms");

                     // final url ="https://mototrackerbd.com/dashboard/customer_bill_vms";
                     // final url ="https://safetygpstracker.com.bd/vms";
                    //  final url ="https://www.maktro.com/mgt/pay/";
                      final url ="";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Browser(
                                dashboardName: "VMS",
                                dashboardURL: url,
                              )));
                    },
                    child: Container(
                        padding: EdgeInsets.all(18),

                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius:BorderRadius.all(Radius.circular(15)),
                          // borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        // color: Colors.white,
                        //color: Color(0x99FFFFFF),
                        child:   Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('VMS',  style: TextStyle(
                                  fontSize: 16, color: SOFT_GREY)),
                              Image.asset("assets/settingicon/report.png", height: 30,width: 30),

                            ]
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
  Widget _buildManues(){
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
             // _launchURL("https://safetygpstracker.com.bd/single_page/2");

             // _launchURL("https://mototrackerbd.com/terms-conditions");

            //  final url ="https://safetygpstracker.com.bd/single_page/2";
              //final url ="https://mototrackerbd.com/terms-conditions";
             // final url ="https://www.maktro.com";
              final url ="https://sites.google.com/view/assiantrack/home?authuser=8";

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Browser(
                        dashboardName: "Terms And Conditions",
                        dashboardURL: url,
                      )));
             /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => termsandconditions()),
              );*/
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                   /* border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),*/
                    borderRadius: BorderRadius.only(topLeft:  Radius.circular(10) ,topRight:  Radius.circular(10) )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.file_copy_rounded,size: 30, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('الشروط والاحكام', style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

              //_launchURL("https://safetygpstracker.com.bd/single_page/2");
             // _launchURL("https://mototrackerbd.com/privacy-policy/");

             // final url ="https://mototrackerbd.com/privacy-policy";
              //final url ="https://safetygpstracker.com.bd/single_page/2";
              final url ="https://sites.google.com/view/assiantrack/privacy?authuser=8";
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Browser(
                        dashboardName: "Privacy Policy",
                        dashboardURL: url,
                      )));
             /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => privacypolicy()),
              );*/
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[100]!
                    ),
                    borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10) ,bottomRight:  Radius.circular(10) )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip,size: 30, color: Colors.yellow),
                        SizedBox(width: 12),
                        Text('الخصوصية', style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              changePasswordDialog();
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                  //  borderRadius: BorderRadius.only(topLeft:  Radius.circular(10) ,topRight:  Radius.circular(10) )

                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.change_circle,size: 30, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Change Password'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => reportselection()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[100]!
                    ),
                    borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10) ,bottomRight:  Radius.circular(10) )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stacked_bar_chart,size: 30, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Reports'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),

          SizedBox(height: 4),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlertListPage()),
              );

            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('قائمة التنبيهات', style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    // Switch(
                    //   value: _val,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _val = value;
                    //     });
                    //   },
                    // ),
                  ],
                )
            ),
          ),
          SizedBox(height: 4),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivateAlert()),
              );

            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('تفعيل التنبيهات', style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    // Switch(
                    //   value: _val,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _val = value;
                    //     });
                    //   },
                    // ),
                  ],
                )
            ),
          ),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GeofenceListPage()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    /* border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),*/
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  //  borderRadius: BorderRadius.only(topLeft:  Radius.circular(10) ,topRight:  Radius.circular(10) )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle_outlined,size: 30, color: Colors.red),
                        SizedBox(width: 12),
                        Text('GeofenceSetting'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => addalert()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[100]!
                    ),
                    borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10) ,bottomRight:  Radius.circular(10) )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed,size: 30, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Overspeeding'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),
          SizedBox(height: 12),

          SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => changedevicesettings()));


            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
               // padding: EdgeInsets.fromLTRB(12, 10, 2, 10),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  /* border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),*/
                  borderRadius: BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0.0, 2.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],


                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/speedoicon/assets_images_vehseticon.png", height: 30,width: 30),

                        //Icon(Icons.logout,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('ChangeDeviceSetting'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),

          // SizedBox(height: 12),
          // GestureDetector(
          //   behavior: HitTestBehavior.translucent,
          //   onTap: (){
          //
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => registerscreen()),
          //     );
          //
          //   },
          //   child: Container(
          //       alignment: Alignment.center,
          //       padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
          //       // padding: EdgeInsets.fromLTRB(12, 10, 2, 10),
          //       margin: EdgeInsets.only(bottom: 8),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //          border: Border.all(
          //               width: 1,
          //               color: Colors.grey[300]!
          //           ),
          //         borderRadius: BorderRadius.all(
          //             Radius.circular(10) //         <--- border radius here
          //         ),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.grey.withOpacity(0.5),
          //             offset: Offset(0.0, 2.0), //(x,y)
          //             blurRadius: 6.0,
          //           ),
          //         ],
          //
          //
          //       ),
          //       child:Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Row(
          //             children: [
          //               Image.asset("assets/speedoicon/assets_images_vehseticon.png", height: 30,width: 30),
          //
          //               //Icon(Icons.logout,size: 30, color: Colors.red.shade700),
          //               SizedBox(width: 12),
          //               Text('RegisterANewDevice'.tr, style: TextStyle(
          //                   color: CHARCOAL, fontWeight: FontWeight.bold
          //               )),
          //             ],
          //           ),
          //           Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
          //         ],
          //       )
          //   ),
          // ),
          SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

              changeLanguageDialog();

            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                // padding: EdgeInsets.fromLTRB(12, 10, 2, 10),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  /* border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),*/
                  borderRadius: BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(0.0, 2.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],


                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/speedoicon/assets_images_vehseticon.png", height: 30,width: 30),

                        //Icon(Icons.logout,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('ChangeLanguage'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),

          SizedBox(height: 12),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){


            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('NotificationSetting'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Switch(
                      value: _val,
                      onChanged: (value) {
                        setState(() {
                          _val = value;
                          prefs.setBool("notival", _val);
                          if(_val==false){
                           // updateToken();
                          }
                        });
                      },
                    ),
                  ],
                )
            ),
          ),
          SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){

             String username =  StaticVarMethod.username;
             username = username.replaceAll(RegExp('[^A-Za-z0-9]'), '');
             print(username);

              // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
              // firebaseMessaging.unsubscribeFromTopic(username).then((_) {
              //   print("unsubscribed to topic " + username);
              // });
              prefs.remove("email");
              prefs.remove("password");
              prefs.remove("popup_notify");
              prefs.remove("user");
              prefs.remove("user_api_hash");
              prefs.remove("user_api_hash");
              prefs.setBool("notival", false);

             updateToken();

             // prefs.clear();
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  //  builder: (context) => signin()),
                    builder: (context) => SignInScreen()),
              );

            },
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(10) //         <--- border radius here
                    )
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.logout,size: 30, color: Colors.red.shade700),
                        SizedBox(width: 12),
                        Text('SignOut'.tr, style: TextStyle(
                            color: CHARCOAL, fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 30, color: SOFT_GREY),
                  ],
                )
            ),
          ),

        ],
      ),
    );
  }


  Future<void> updateToken() async{

    String token=StaticVarMethod.notificationToken;
    print(token);
    gpsapis.deactivateFCM(token);

      print("Remove notification successfuly");

  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }


  }


  launchWhatsApp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+8801711927826',
      text: "Hey! I'm inquiring about the Tracking listing",
    );
    await launch('$link');
  }

  void changeLanguageDialog() {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 450.0,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  Get.updateLocale(const Locale('en',"US"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('English', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                 // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('fr',"CA"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('French', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                  // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('de',"DE"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Germany', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){

                                  Get.updateLocale(const Locale('tr',"TR"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Turkey', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                  // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('ar',"SA"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Arabic (Saudi Arabia)', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                  // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('ar',"EG"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Arabic (Morocco)', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                  // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('ur',"PK"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Urdu', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),

                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  //arabic
                                  // Get.updateLocale(const Locale('ar',"EG"));
                                  Get.updateLocale(const Locale('pt',"BR"));
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(12, 1, 2, 1),
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey[300]!
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10) //         <--- border radius here
                                        )
                                    ),
                                    child:Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.language,size: 30, color: Colors.red.shade700),
                                            SizedBox(width: 12),
                                            Text('Portuguese (Brazil)', style: TextStyle(
                                                color: CHARCOAL, fontWeight: FontWeight.bold
                                            )),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }
  void changePasswordDialog() {
    Dialog simpleDialog = Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 250.0,
                width: 400.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              new Container(
                                child: new TextField(
                                  controller: _newPassword,
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'New Password'),
                                  obscureText: true,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              new Container(
                                child: new TextField(
                                  controller: _retypePassword,
                                  decoration: new InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Retype Password'),
                                  obscureText: true,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                    //color: Colors.red,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel',
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                   // color: CustomColor.primaryColor,
                                    onPressed: () {
                                      updatePassword();
                                    },
                                    child: Text('Ok',
                                      style: TextStyle(
                                          fontSize: 18.0, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
  }

  void updatePassword() {
    if (_newPassword.text == _retypePassword.text) {
      // Map<String, String> requestBody = <String, String>{
      //   'password': _newPassword.text
      // };
      // gpsapis.changePassword(_newPassword.toString()).then((value) => {
      //   AlertDialogCustom().showAlertDialog(
      //       context,'Password Updated Successfully','Change Password','ok')
      // });
      var result= gpsapis.changePassword(_newPassword.text.toString());
      if(result != null){
        AlertDialogCustom().showAlertDialog(
            context,'Password Updated Successfully','Change Password','ok');
      }
    } else {
      AlertDialogCustom().showAlertDialog(
          context,'Password Not Same','Failed','ok');
    }
  }
}


