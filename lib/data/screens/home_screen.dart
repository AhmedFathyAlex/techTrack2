// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:maktrogps/config/app_text.dart';
import 'package:maktrogps/config/apps/images.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:maktrogps/data/screens/listscreen.dart';
import 'package:maktrogps/data/screens/playbackselection.dart';
import 'package:maktrogps/data/screens/reports/reportselection.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:maktrogps/ui/reusable/Mycolor/MyColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


//Develope by M.Shoaib
//whatsapp number: +923194021317
//whatsapp number 2: +923414910057
class _HomeScreenState extends State<HomeScreen> {

  //NearBy Search
  void launchGoogleMapsNearbySearch(String query, int radius) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query&radius=$radius';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }
  launchWebUrl(String url) async {
    // const url = url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<String> imageUrls = [
    'https://maktro.com/ai/1.jpg',
    'https://maktro.com/ai/2.jpg',
    'https://maktro.com/ai/3.jpg',
  ];

  int _currentIndex = 0;

  final CarouselController _carouselController = CarouselController();
  Map<String, dynamic> devicesSettingsList = HashMap();

  int key = 0;
  SharedPreferences? prefs;

  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _allVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _expiredVehicles = [];
  List<deviceItems> _stoppedVehicles = [];
  List<deviceItems> _offlineVehicles = [];
  List<EventsData> eventList = [];

  List<deviceItems> devicesList = [];
  late ObjectStore objectStore;



  List<EventsData> _geofencealets = [];
  List<EventsData> _overspeedalets = [];
  List<EventsData> _idlealets = [];
  List<EventsData> _stopalets = [];
  List<EventsData> _ignitiononalets = [];
  List<EventsData> _ignitionoffalets = [];
  Future<void> getnotiList() async {
    gpsapis api = new gpsapis();
    try {
      eventList = await api.getEventsList(StaticVarMethod.user_api_hash);
      if (eventList.isNotEmpty) {
        for (int i = 0; i < eventList.length; i++) {
          EventsData model = eventList.elementAt(i);
          if (model.name.toString().toLowerCase().contains("geofance") ||
              model.name.toString().toLowerCase().contains("zone")) {
            _geofencealets.add(eventList.elementAt(i));
          } else if (model.name
              .toString()
              .toLowerCase()
              .contains("overspeed")) {
            _overspeedalets.add(eventList.elementAt(i));
          } else if (model.name.toString().toLowerCase().contains("idle")) {
            _idlealets.add(eventList.elementAt(i));
          } else if (model.name.toString().toLowerCase().contains("stop")) {
            _stopalets.add(eventList.elementAt(i));
          } else if (model.name
              .toString()
              .toLowerCase()
              .contains("ignition on")) {
            _ignitiononalets.add(eventList.elementAt(i));
          } else if (model.name
              .toString()
              .toLowerCase()
              .contains("ignition off")) {
            _ignitionoffalets.add(eventList.elementAt(i));
          }
        }
        if (mounted) {
          setState(() {});
        }
      } else {}
    } catch (e) {
      //Fluttertoast.showToast(msg: 'Not exist', toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  initState() {
    getnotiList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    _expiredVehicles = [];
    _allVehicles = [];
    _offlineVehicles = [];

    objectStore = Provider.of<ObjectStore>(context);
    devicesList = objectStore.objects;

    _allVehicles = devicesList;


    // DateTime now = DateTime.now().add(Duration(days: -15));

    for (int i = 0; i < devicesList.length; i++) {
      deviceItems model = devicesList.elementAt(i);
      String other = model.deviceData!.traccar!.other.toString();
      String stopDuration = model.stopDuration.toString();
      String ignition = "false";
      int hours = 0;

      int difference = 1000;
      var expirationdate = model.deviceData!.expirationDate.toString();
      if (expirationdate.contains("expire")) {
        expirationdate = "Expired";
      } else if (expirationdate.contains("null")) {
        expirationdate = "Not Found";
      } else {
        DateTime date = DateTime.parse(expirationdate);
        final date2 = DateTime.now();
        difference = daysBetween(date2, date);
      }

      if (other.contains("<ignition>")) {
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        ignition = other.substring(startIndex + start.length, endIndex);
      }
      if (other.contains("<ignition>")) {
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        ignition = other.substring(startIndex + start.length, endIndex);
      }
      if (stopDuration.toString().contains("h")) {
        const end = "h";
        final endIndex = stopDuration.indexOf(end);
        //String h = stopDuration.substring(endIndex);
        String result = stopDuration.substring(0, endIndex);
        hours = int.parse(result);
        print(result);
        // print(h);
      }

      //  if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
      // if (hours >23 && ignition.contains("false")) {
      if (model.time.toString().toLowerCase().contains("expire") ||
          difference <= 15) {
        _expiredVehicles.add(devicesList.elementAt(i));
        // Future.delayed(Duration.zero, () => showAlert(context,model.name.toString()));
        print('expire');
      } else if (model.online.toString().contains("offline") &&
          !model.time.toString().contains("Not connected") &&
          !model.time.toString().contains("Expired")) {
        _offlineVehicles.add(devicesList.elementAt(i));
        print('offline');
      } else if (model.time.toString().toLowerCase().contains("expire")) {
        _expiredVehicles.add(devicesList.elementAt(i));
        // Future.delayed(Duration.zero, () => showAlert(context,model.name.toString()));
        print('expire');
      } else if (ignition.contains("true") &&
          !model.online.toString().contains("offline") &&
          double.parse(model.speed.toString()) < 1.0) {
        _idleVehicles.add(devicesList.elementAt(i));
      } else if (model.online.toString().toLowerCase().contains("offline") &&
          model.time.toString().toLowerCase().contains("not connected")) {
        _inactiveVehicles.add(devicesList.elementAt(i));
      } else if (model.online.toString().toLowerCase().contains("online")) {
        _runningVehicles.add(devicesList.elementAt(i));
      } else if (ignition.contains("false") &&
          model.time.toString().toLowerCase() != "not connected" &&
          double.parse(model.speed.toString()) < 1.0) {
        _stoppedVehicles.add(devicesList.elementAt(i));
      }
    }


    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          // title: const Text('GPS SOFT',style: TextStyle(color: deepBlue),),
          title:Image.asset(Images.appBarLogoNew, height: 40),
          bottom: TabBar(
            unselectedLabelColor: Colors.black.withOpacity(0.5),
            labelColor: Colors.black,
            indicatorColor: Colors.blue.shade700,
            tabs: <Widget>[
              Tab(
                icon: Text(
                  AppText.dashboard.tr,
                ),
              ),
              Tab(
                icon: Text(
                  AppText.quickLinks.tr,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Banner".tr,
                              style: TextStyle(
                                color: Colors.black.withOpacity(.6),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const Divider(
                              thickness: 1.5,
                              color: Color(0xfff0f0f0),
                            ),

                            Center(
                              child: Lottie.network(
                                  'https://lottie.host/0ef6ba35-3b1f-41a5-b3ba-cbc311fe280f/xs7lu1tpKt.json',height: 180),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(
                      //height: 230,
                     // width: double.infinity,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: fleetStatus(),
                    ),
                    alertStatus(),

                    Container(
                      margin: EdgeInsets.only(top: 20),
                      // color: Theme.of(context).primaryColor,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(200))),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 30,
                          children: [
                            itemDashboard(
                                'Reports'.tr, CupertinoIcons.doc_chart, Colors.deepOrange),
                            itemDashboard(
                                'History'.tr, CupertinoIcons.clock_fill, Colors.green),
                            // itemDashboard('Vehicle', CupertinoIcons.car, Colors.purple),
                            // itemDashboard('Fuel', CupertinoIcons.cube_box, Colors.brown),
                            // itemDashboard('Revenue', CupertinoIcons.money_dollar_circle, Colors.indigo),
                            // itemDashboard('Upload', CupertinoIcons.add_circled, Colors.teal),
                            // itemDashboard('About', CupertinoIcons.question_circle, Colors.blue),
                            // itemDashboard('Contact', CupertinoIcons.phone, Colors.pinkAccent),
                          ],
                        ),
                      ),
                    ),



                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*   CarouselSlider.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index, realIndex) {
                        final imageUrl = imageUrls[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                      ),
                      carouselController: _carouselController,
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: DotsIndicator(
                        dotsCount: imageUrls.length,
                        position: _currentIndex,
                        decorator: DotsDecorator(
                          color: Colors.grey,
                          activeColor: Colors.blue,
                          size: Size(10, 10),
                          activeSize: Size(12, 12),
                          spacing: EdgeInsets.all(5),
                        ),
                      ),
                    ),*/


                    SizedBox(height: 10,),
                    // Container(
                    //   height: 230,
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10),
                    //     color: Colors.white,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.5),
                    //         spreadRadius: 5,
                    //         blurRadius: 5,
                    //         offset: const Offset(0, 3), // changes position of shadow
                    //       ),
                    //     ],
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           "Banner",
                    //           style: TextStyle(
                    //               color: Colors.black.withOpacity(.6),
                    //               fontWeight: FontWeight.bold
                    //           ),
                    //         ),
                    //         const Divider(
                    //           thickness: 1.5,
                    //           color: Color(0xfff0f0f0),
                    //         ),
                    //
                    //         Center(
                    //           child: Lottie.network(
                    //               'https://lottie.host/0ef6ba35-3b1f-41a5-b3ba-cbc311fe280f/xs7lu1tpKt.json',height: 180),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Container(
                    //   height: 200,
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10),
                    //     color: Colors.white,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.5),
                    //         spreadRadius: 5,
                    //         blurRadius: 5,
                    //         offset: const Offset(0, 3), // changes position of shadow
                    //       ),
                    //     ],
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           AppText.quickLinks,
                    //           style: TextStyle(
                    //               color: Colors.black.withOpacity(.6),
                    //               fontWeight: FontWeight.bold
                    //           ),
                    //         ),
                    //         const Divider(
                    //           thickness: 1.5,
                    //           color: Color(0xfff0f0f0),
                    //         ),
                    //
                    //         SizedBox(height: 10,),
                    //
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //
                    //             /*driving instruction*/
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.drivingInstructorUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/drivingcar.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.driving,style: TextStyle(fontSize: 9),),
                    //                           Text(AppText.instructor,style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             /*get licence*/
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.getLicenceUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/get-license.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.getLicence,style: TextStyle(fontSize: 9),),
                    //                           // Text("Lience",style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             /*traffic signs*/
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.trafficSignsUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/traffic-signs.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.traffic,style: TextStyle(fontSize: 9),),
                    //                           Text(AppText.signs,style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //
                    //           ],
                    //         ),
                    //         SizedBox(height: 10,),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             //brta instruction
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.brtaUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/brta-instruction.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.brta,style: TextStyle(fontSize: 9),),
                    //                           Text(AppText.brtaInstructor,style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             //car knowledge
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.carKnowledgeUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/car-knowledge.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.car,style: TextStyle(fontSize: 9),),
                    //                           Text(AppText.knowledge,style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             //blogs
                    //             InkWell(
                    //               onTap: ()=>launchWebUrl(AppText.blogsUrl),
                    //               child: Container(
                    //                 width: 105,
                    //                 height: 60,
                    //                 decoration: BoxDecoration(
                    //                   color: Color(0xfff9f9f9),
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                       color: Colors.grey.withOpacity(0.5),
                    //                       spreadRadius: 5,
                    //                       blurRadius: 5,
                    //                       offset: const Offset(0, 3), // changes position of shadow
                    //                     ),
                    //                   ],
                    //                 ),
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: Row(
                    //                     children: [
                    //                       // Icon(Icons.car_crash,size: 30,),
                    //                       Image.asset("assets/images/blogs.png",scale: 15,),
                    //                       SizedBox(width: 8,),
                    //                       Column(
                    //                         mainAxisAlignment: MainAxisAlignment.center,
                    //                         crossAxisAlignment: CrossAxisAlignment.start,
                    //                         children: [
                    //                           Text(AppText.blogs,style: TextStyle(fontSize: 9),),
                    //                           // Text("Instructor",style: TextStyle(fontSize: 9),),
                    //                         ],
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //
                    //           ],
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 20,),

                    Container(
                      height: 340,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.nearByPlaces.tr,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(.6),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const Divider(
                              thickness: 1.5,
                              color: Color(0xfff0f0f0),
                            ),

                            SizedBox(height: 10,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Hospital
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.hospital,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Image.asset("assets/nearbyplaceicon/hospital.png",scale: 10,),
                                          SizedBox(width: 8,),
                                           Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Hospital".tr,style: TextStyle(fontSize: 9),),
                                              // Text("Instructor",style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //ATM
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.atm,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/atm.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("ATM".tr,style: TextStyle(fontSize: 9),),
                                              // Text("Lience",style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Mosque
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.mosque,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/mosque.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Mosque".tr,style: TextStyle(fontSize: 9),),

                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Restaurant
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.restaurant,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/restaurant.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Restaurant".tr,style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Gas Station
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.gasStation,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/gas-pump.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Gas Station".tr,style: TextStyle(fontSize: 9),),

                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Petrol Pump
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.petrolPump,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/petrol-pump.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Petrol Pump".tr,style: TextStyle(fontSize: 9),),
                                              // Text("Instructor",style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Hotel
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.hotel,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/hotel.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Hotel".tr,style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Shopping Mall
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.shoppingMall,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/mall.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Shopping Mall".tr,style: TextStyle(fontSize: 8),),

                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Police Station
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.policeStation,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/police-station.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Police Station".tr,style: TextStyle(fontSize: 8),),
                                              // Text("Instructor",style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Service Point
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.servicePoint,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/service-point.png",scale: 11,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Service Point".tr,style: TextStyle(fontSize: 8),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //railway-station
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.trainStation,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/railway-station.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Train Station".tr,style: TextStyle(fontSize: 9),),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Bus Stop
                                InkWell(
                                  onTap: ()=>launchGoogleMapsNearbySearch(AppText.busStop,AppText.radius),
                                  child: Container(
                                    width: 105,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff9f9f9),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Icon(Icons.car_crash,size: 30,),
                                          Image.asset("assets/nearbyplaceicon/bus-stop.png",scale: 10,),
                                          SizedBox(width: 8,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Bus Stop".tr,style: TextStyle(fontSize: 8),),

                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 60,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget fleetStatus() {


    double all =  _allVehicles.length.toDouble(),offline=_offlineVehicles.length.toDouble(), moving = _runningVehicles.length.toDouble(), idle = _idleVehicles.length.toDouble(), stop = _stoppedVehicles.length.toDouble(), disconnect = 0, noData = _inactiveVehicles.length.toDouble(), expired =_expiredVehicles.length.toDouble();


    final colorList = <Color>[
      MyColor.ONLINE_COLOR,
      MyColor.IDLE_COLOR,
      MyColor.STOP_COLOR,
      MyColor.INACTIVE_COLOR,
      Colors.black,
    ];

    final dataMap = <_PieData>[
      _PieData(
        'Running'.tr,
        moving,
        moving.toStringAsFixed(0),
        MyColor.ONLINE_COLOR,
      ),
      _PieData('Offline'.tr, offline, offline.toStringAsFixed(0), Colors.blue),
      _PieData('Expired'.tr, expired, expired.toStringAsFixed(0), Colors.grey),
      _PieData(
        'Idle'.tr,
        idle,
        idle.toStringAsFixed(0),
        MyColor.IDLE_COLOR,
      ),
      _PieData('Stopped'.tr, stop, stop.toStringAsFixed(0), MyColor.STOP_COLOR),
      _PieData('Inactive'.tr, disconnect, disconnect.toStringAsFixed(0),
          MyColor.INACTIVE_COLOR),
      _PieData('No Data'.tr, noData, noData.toStringAsFixed(0), Colors.black),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Vehicle Status'.tr,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 280,
                width: 180,
                alignment: Alignment.centerLeft,
                child: SfCircularChart(
                    legend: Legend(
                        isVisible: false,
                        overflowMode: LegendItemOverflowMode.wrap,
                        position: LegendPosition.right),
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                          widget: Text(all.toStringAsFixed(0),
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  fontSize: 25))),
                    ],
                    series: <DoughnutSeries<_PieData, String>>[
                      DoughnutSeries<_PieData, String>(
                          explode: true,
                          explodeOffset: '50%',
                          radius: '100%',
                          innerRadius: '50%',
                          onPointTap: (val) {
                            // print(dataMap[val.pointIndex!].xData);
                            if (dataMap[val.pointIndex!].xData ==
                                "Moving".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 1;
                              // });
                            } else if (dataMap[val.pointIndex!].xData ==
                                "Idle".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 2;
                              // });
                            } else if (dataMap[val.pointIndex!].xData ==
                                "Stop".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 3;
                              // });
                            } else if (dataMap[val.pointIndex!].xData ==
                                "Inactive".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 4;
                              // });
                            } else if (dataMap[val.pointIndex!].xData ==
                                "No Data".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 5;
                              // });
                            } else if (dataMap[val.pointIndex!].xData ==
                                "Offline".tr) {
                              // widget.parent!.setState(() {
                              //   Util.selectedIndex = 2;
                              //   objectFilter  = 5;
                              // });
                            }
                          },
                          dataSource: dataMap,
                          xValueMapper: (_PieData data, _) => data.xData,
                          yValueMapper: (_PieData data, _) => data.yData,
                          dataLabelMapper: (_PieData data, _) =>
                          data.text,
                          pointColorMapper: (_PieData data, _) =>
                          data.color,
                          dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              showZeroValue: false,
                              labelPosition:
                              ChartDataLabelPosition.inside,
                              color: Colors.white30,
                              useSeriesColor: true,
                              borderColor: Colors.white30,
                              borderWidth: 10,
                              borderRadius: 0.2)),
                    ])),
            Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.green,
                          ),
                          Text("Running".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.red,
                          ),
                          Text("Stopped".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.yellow,
                          ),
                          Text("Idle".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.blue,
                          ),
                          Text("Offline".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.grey,
                          ),
                          Text("No Data".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/trackit/dashboardchart.png",
                            height: 20,
                            width: 20,
                            color: Colors.red[900]!,
                          ),
                          Text("Expired".tr,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400))
                        ],
                      ),
                    ),
                  ]),
            )
          ],
        )
      ],
    );
  }

  Widget alertStatus() {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/alerts");
        },
        child: Card(
            child: Container(
                padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 1),
                          color: Theme.of(context).primaryColor.withOpacity(.2),
                          spreadRadius: 1,
                          blurRadius: 1)
                    ]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Alerts(Today)'.tr,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10,top: 10),
                        //padding: EdgeInsets.all(1.5),
                        width: 300,
                        height: 0.5,
                        color: ( Colors.grey[400]!),
                      ),
                      // loadEventsData(),
                      loadEventsData1()
                    ]))));
  }

  Widget loadEventsData1() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(right: 12),
          margin: EdgeInsets.only(right: 10),
          // width: 280,
          height: 50,
          // width: 280,
          // height: 52,
          // width: MediaQuery.of(context).size.width / 1.1,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2.0,
                offset: const Offset(2.0, 2.0),
              ),
            ],
            // gradient: LinearGradient(
            //   colors: [
            //     Color(0xffff6e02),
            //     Color(0xffffff00) /*, Color(0xffff6d00)*/
            //   ],
            //   begin: FractionalOffset.centerLeft,
            //   end: FractionalOffset.centerRight,
            // ),
            gradient: LinearGradient(
              colors: [
                Color(0xff373737),
                Colors.black26 /*, Color(0xffff6d00)*/
              ],
              begin: FractionalOffset.centerLeft,
              end: FractionalOffset.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                  // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  // textStyle: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold)
                ),
                onPressed: () {
                  // StaticVarMethod.notificationback = false;
                  //
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => NotificationsPage()),
                  // );
                  // print("TotalAlerts");
                },
                icon: Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                ),
                // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                label: Text(
                  "TodayAlerts".tr,
                  style: TextStyle(color: Colors.white),
                ), //label text
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(eventList.length
                    .toString() /*,style: TextStyle(color: Colors.white)*/),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(right: 5,left: 5),
              margin: EdgeInsets.only(right: 13, top: 10),
              width: 145,
              height: 50,
              //  width: MediaQuery.of(context).size.width / 2.3,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xff962bb4),
                //     Color(0xff5467d8),
                //     Color(0xff2394f3)
                //   ],
                //   begin: FractionalOffset.centerLeft,
                //   end: FractionalOffset.centerRight,
                // ),

                gradient: LinearGradient(
                  colors: [
                    Color(0xff373737),
                    Colors.black26 /*, Color(0xffff6d00)*/
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
              GestureDetector(
                // onTap: () {
                //   StaticVarMethod.eventList = _geofencealets;
                //   StaticVarMethod.notificationback = false;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()),
                //   );
                //   print("Geofence");
                // },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.fence,
                      color: Colors.white,
                      size: 30,
                    ),
                    // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                    Text("Geofence".tr + " ",
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child:Text(_geofencealets.length.toString(),),
                    )
                  ],
                ),
                //label text
              ),

            ),
            Container(
              padding: EdgeInsets.only(right: 5,left: 5),
              margin: EdgeInsets.only(right: 13, top: 10),
              width: 145,
              height: 50,
              // width: MediaQuery.of(context).size.width / 2.3,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],

                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xffe84842),
                //     Color(0xff5467d8),
                //     Color(0xff2394f3)
                //   ],
                //   begin: FractionalOffset.centerLeft,
                //   end: FractionalOffset.centerRight,
                // ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xff373737),
                    Colors.black26 /*, Color(0xffff6d00)*/
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
              GestureDetector(

                // onTap: () {
                //   StaticVarMethod.eventList = _overspeedalets;
                //   StaticVarMethod.notificationback = false;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()),
                //   );
                //   print("Overspeed");
                // },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.speed,
                      color: Colors.white,
                      size: 30,
                    ),
                    // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                    Text("Overspeed".tr,
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child:Text(_overspeedalets.length.toString(),),
                    )
                  ],
                ),
                //label text
              ),

            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(right: 5,left: 5),
              margin: EdgeInsets.only(right: 13, top: 10),
              width: 145,
              height: 50,
              //  width: MediaQuery.of(context).size.width / 2.3,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xffa2969a),
                //     Color(0xffc36080),
                //     Color(0xffe62666)
                //   ],
                //   begin: FractionalOffset.centerLeft,
                //   end: FractionalOffset.centerRight,
                // ),

                gradient: LinearGradient(
                  colors: [
                    Color(0xff373737),
                    Colors.black26 /*, Color(0xffff6d00)*/
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
              GestureDetector(

                // onTap: () {
                //   StaticVarMethod.eventList = _idlealets;
                //
                //   StaticVarMethod.notificationback = false;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()),
                //   );
                //   print("Excess Idle");
                // },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                    // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                    Text("ExcessIdle".tr + " ",
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child:Text(_idlealets.length.toString(),),
                    )
                  ],
                ),

                // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                //label text
              ),


            ),
            Container(
              padding: EdgeInsets.only(right: 5,left: 5),
              margin: EdgeInsets.only(right: 13, top: 10),
              width: 145,
              height: 50,
              // width: MediaQuery.of(context).size.width / 2.3,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xff7a11f5),
                //     Color(0xff5467d8),
                //     Color(0xff010f1c)
                //   ],
                //   begin: FractionalOffset.centerLeft,
                //   end: FractionalOffset.centerRight,
                // ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xff373737),
                    Colors.black26 /*, Color(0xffff6d00)*/
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
              GestureDetector(

                // onTap: () {
                //   StaticVarMethod.eventList = _stopalets;
                //
                //   StaticVarMethod.notificationback = false;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()),
                //   );
                //   print("Parked");
                // },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.local_parking,
                      color: Colors.white,
                      size: 30,
                    ),
                    // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                    Text("Parked".tr + " ",
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child:Text(_stopalets.length.toString(),),
                    )
                  ],
                ),
                //label text
              ),

            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(right: 5,left: 5),
              margin: EdgeInsets.only(right: 13, top: 10),
              width: 145,
              height: 40,
              //  width: MediaQuery.of(context).size.width / 2.3,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xff9fff0e),
                //     Color(0xff5467d8),
                //     Color(0xfff8d000)
                //   ],
                //   begin: FractionalOffset.centerLeft,
                //   end: FractionalOffset.centerRight,
                // ),

                gradient: LinearGradient(
                  colors: [
                    Color(0xff373737),
                    Colors.black26 /*, Color(0xffff6d00)*/
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
              GestureDetector(
                // onTap: () {
                //   StaticVarMethod.eventList = _ignitiononalets;
                //   StaticVarMethod.notificationback = false;
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => NotificationsPage()),
                //   );
                //
                //   print("Ignition On");
                // },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.key,
                      color: Colors.white,
                      size: 25,
                    ),
                    // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                    Text("Ignition On".tr + " ",
                        style: TextStyle(
                            color: Colors.white, fontSize: 10)),
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child:Text(_ignitiononalets.length.toString(),),
                    )
                  ],
                ),

              ),

            ),
            Container(
                padding: EdgeInsets.only(right: 5,left: 5),
                margin: EdgeInsets.only(right: 13, top: 10),
                width: 145,
                height: 40,
                // width: MediaQuery.of(context).size.width / 2.3,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2.0,
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color(0xffe84842),
                  //     Color(0xff00ff80),
                  //     Color(0xff74ff00)
                  //   ],
                  //   begin: FractionalOffset.centerLeft,
                  //   end: FractionalOffset.centerRight,
                  // ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff373737),
                      Colors.black26 /*, Color(0xffff6d00)*/
                    ],
                    begin: FractionalOffset.centerLeft,
                    end: FractionalOffset.centerRight,
                  ),
                ),
                child:
                GestureDetector(
                  // onTap: () {
                  //   StaticVarMethod.eventList = _ignitionoffalets;
                  //
                  //   StaticVarMethod.notificationback = false;
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => NotificationsPage()),
                  //   );
                  //   print("Ignition Off");
                  // },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.key_off,
                        color: Colors.white,
                        size: 25,
                      ),
                      // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                      Text("Ignition Off".tr + " ",
                          style: TextStyle(
                              color: Colors.white, fontSize: 10)),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child:Text(_ignitionoffalets.length.toString(),),
                      )
                    ],
                  ),
                )

            ),
          ],
        ),
      ],
    );
  }

  itemDashboard(String title, IconData iconData, Color background) => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 5),
              color: Theme.of(context).primaryColor.withOpacity(.2),
              spreadRadius: 2,
              blurRadius: 5)
        ]),
    child: GestureDetector(
      onTap: () {
        if (title.toString().contains("Reports".tr)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => reportselection()),
          );
        }
        else if (title.toString().contains("Vehicle".tr)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => listscreen()),
          );
        }
        else if (title.toString().contains("Fuel")) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => fuelscreen()),
          // );
        }
        else {
          //StaticVarMethod.isplaybackselection = true;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => playbackselection()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: Colors.white)),
          const SizedBox(height: 8),
          Text(title.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium)
        ],
      ),
    ),
  );

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.text, this.color);
  final String xData;
  final num yData;
  final String text;
  final Color color;
}