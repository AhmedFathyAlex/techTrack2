import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/data/model/Services.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/data/model/services_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


Color defaultBackground = Colors.grey;/*Color(0xFFF2F2F2);*/
Color kBlueColor = Color(0xFF0060A4);
Color kOrangeColor = Color(0xFFF26611);
Color kBlackColor = Color(0xFF343434);

class StaticVarMethod{
  static bool isInitLocalNotif = false;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool isDarkMode = false;
  static String? user_api_hash = "\$2y\$10\$yUmXjzCeKUZ1fb8SHRZJTe7AWBmVhDAMrSmoi6DVxkicvS3rtmW6G";
  static List<deviceItems> devicelist= [];
  static List<services_model> serviceslist= [];
  static List<EventsData> eventList= [];
  static String deviceName= "";
  static String username= "";
  static String deviceId= "";
  static String imei= "87858585858";
  static String simno= "";
  static List<deviceItems> expirelist= [];

  static int reportType=1;
  static bool isplaybackselection = true;



  static String baseurlall= "http://5.189.158.9";


  // static String listimageurl= 'http://38.gpsautomototrack.com/assets/applogo/sftech.png';
  // static String loginimageurl= 'http://38.gpsautomototrack.com/assets/applogo/sftech.png';
  // static String splashimageurl= 'http://38.gpsautomototrack.com/assets/applogo/sftech.png';
  //



  //notification
  static String type = "";
  static String speed = "";
  static String time = "";
  static String message = "";
  static double lat= 0.0;
  static double lng=0.0;
  static String devicestatus = "Stopped";
  static String deviceweight = "Not Found";


  static Color devicestatuscolor = Colors.red;
  static Color notibackcolor =  Colors.white;

  static SharedPreferences? pref_static;
  static int signinpage=1;
  static String notificationToken="";
  static bool notificationback=true;
  static String reporturl= "";
  static String fromdate= DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  static String fromtime="00:01";
  static String todate= DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1));
  static String totime= DateFormat('HH:mm').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour, DateTime.now().minute));
  static const String myEasytrax = 'My EasyTrax';
  static const String faq = 'FAQ';
  static const String termsofUse = 'Terms of Use';
  static const String logout = 'Logout';

  static const List<String> choices = <String>[
    myEasytrax,
    faq,
    termsofUse,
    logout
  ];
}