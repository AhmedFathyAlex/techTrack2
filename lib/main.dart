import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:maktrogps/provider/theme_changer_provider.dart';
import 'package:maktrogps/utils/LocalNotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/static.dart';
import 'data/screens/splashscreen.dart';
import 'getx_localization/languages.dart';
import 'mvvm/view_model/objects.dart';


class MyHttpoverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=>true;
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  HttpOverrides.global= MyHttpoverrides();
  runApp(const MyHomePage(title: "title"));
}





class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    checkPreference();
    super.initState();

    if (Platform.isIOS) {


    }

    LocalNotificationService.initialize(context);

  }

  void checkPreference() async {
    StaticVarMethod.pref_static = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [

        ChangeNotifierProvider(create: (_) => theme_changer_provider()),
        ChangeNotifierProvider(create: (_) => ObjectStore()),
      ],
      child: Builder(
          builder: (context) {
            final themeChanger = Provider.of<theme_changer_provider>(context);
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: themeChanger.thememode,
              translations: languages(),
              locale: const Locale('ar',"SA"),
              fallbackLocale: const Locale('ar',"SA"),
              theme: ThemeData(
                  brightness: Brightness.light,
                  primarySwatch: Colors.indigo
              ),
              darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.purple
              ),
              home: SplashScreen(),
             // home: tasks(),
              builder: EasyLoading.init(),
            );
          }
      ),
    );
  }
}
