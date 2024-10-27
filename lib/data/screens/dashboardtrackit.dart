import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_transition_mixin.dart';
import 'package:maktrogps/data/model/Services.dart';
import 'package:maktrogps/data/model/services_model.dart';
import 'package:maktrogps/data/screens/expirelist.dart';
import 'package:maktrogps/data/screens/listscreen.dart';
import 'package:maktrogps/data/screens/playbackselection.dart';
import 'package:maktrogps/data/screens/reports/reportselection.dart';
import 'package:maktrogps/data/screens/serviceslist.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';

import 'dart:collection';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/static.dart';
import '../../res/AssetsRes.dart';
import '../../ui/reusable/Mycolor/MyColor.dart';
import '../datasources.dart';
import '../model/devices.dart';
import '../model/events.dart';
import 'fuelscreen.dart';
import 'notificationscreen.dart';

class Dashboardtrackit extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<Dashboardtrackit> {
  int touchedIndex = -1;
  // late ObjectStore objectStore;
  // late EventsStore eventsStore;
  // late DashboardStore dashboardStore;
  // Map<String, ObjectResponse> devicesList = HashMap();
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

  @override
  initState() {
    //notiList = Consts.notiList;
    getnotiList();
    checkPreference();

    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
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

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 0.0,
          title: Container(
              padding: const EdgeInsets.only(top: 0.0, left: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'لوحة التحكم',
                    style: TextStyle(
                        fontFamily: "Sofia",
                        fontWeight: FontWeight.w900,
                        fontSize: 20.0,
                        color: Colors.black),
                  ),
                  InkWell(
                    onTap: () {
                      launch("tel://" + prefs!.getString("PREF_SUPPORT_NO")!);
                    },
                    child: prefs != null
                        ? prefs!.getString("PREF_SUPPORT_NO") != null
                            ? Icon(Icons.support_agent_outlined)
                            : Container()
                        : Container(),
                  )
                ],
              )),
          backgroundColor: Colors.white,
        ),
        body: dashboardView());
  }

  Widget dashboardView() {
    // objectStore = Provider.of<ObjectStore>(context);
    // eventsStore = Provider.of<EventsStore>(context);
    // dashboardStore = Provider.of<DashboardStore>(context);
    // devicesList = objectStore.objects;
    // devicesSettingsList = objectStore.objectSettings;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 0),
      margin: EdgeInsets.all(10),
      child: ListView(
        //padding: EdgeInsets.zero,
        children: [
          fleetStatus(),
          Flex(
              direction: Axis.horizontal,
              children: [Expanded(child: alertStatus())]),
          fleetIdle(),
          Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    child:
                maintenanceReminder()),
              ]),
          RenewalReminder(),
        // Precautions(),
       /*   Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text('Hello Ahad!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white
                  )),
                  subtitle: Text('Good Morning', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white54
                  )),
                  trailing: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/user.JPG'),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),*/
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
                      'التقارير', CupertinoIcons.doc_chart, Colors.deepOrange),
                  itemDashboard(
                      'استعادة خط السير', CupertinoIcons.clock_fill, Colors.green),
                  // itemDashboard('Vehicle', CupertinoIcons.car, Colors.purple),
                 //  itemDashboard('Fuel', CupertinoIcons.cube_box, Colors.brown),
                  // itemDashboard('Revenue', CupertinoIcons.money_dollar_circle, Colors.indigo),
                  // itemDashboard('Upload', CupertinoIcons.add_circled, Colors.teal),
                  // itemDashboard('About', CupertinoIcons.question_circle, Colors.blue),
                  // itemDashboard('Contact', CupertinoIcons.phone, Colors.pinkAccent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
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
            if (title.toString().contains("Reports") || title.toString().contains("التقارير")) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => reportselection()),
              );
            }
            else if (title.toString().contains("Vehicle")) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => listscreen()),
              );
            }
            else if (title.toString().contains("Fuel")) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => fuelscreen()),
              );
            }
            else {
              StaticVarMethod.isplaybackselection = true;
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
      _PieData('Offline', offline, offline.toStringAsFixed(0), Colors.blue),
      _PieData('expired', expired, expired.toStringAsFixed(0), Colors.grey),
      _PieData(
        'Idle'.tr,
        idle,
        idle.toStringAsFixed(0),
        MyColor.IDLE_COLOR,
      ),
      _PieData('Stopped'.tr, stop, stop.toStringAsFixed(0), MyColor.STOP_COLOR),
      _PieData('InActive'.tr, disconnect, disconnect.toStringAsFixed(0),
          MyColor.INACTIVE_COLOR),
      _PieData('No Data', noData, noData.toStringAsFixed(0), Colors.black),
    ];

    return Card(
      child: Container(
          padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
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
                'Vehicle Status'.tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 300,
                      width: 210,
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
                                radius: '80%',
                                innerRadius: '50%',
                                onPointTap: (val) {
                                  // print(dataMap[val.pointIndex!].xData);
                                  if (dataMap[val.pointIndex!].xData ==
                                      "Moving") {
                                    // widget.parent!.setState(() {
                                    //   Util.selectedIndex = 2;
                                    //   objectFilter  = 1;
                                    // });
                                  } else if (dataMap[val.pointIndex!].xData ==
                                      "Idle") {
                                    // widget.parent!.setState(() {
                                    //   Util.selectedIndex = 2;
                                    //   objectFilter  = 2;
                                    // });
                                  } else if (dataMap[val.pointIndex!].xData ==
                                      "Stop") {
                                    // widget.parent!.setState(() {
                                    //   Util.selectedIndex = 2;
                                    //   objectFilter  = 3;
                                    // });
                                  } else if (dataMap[val.pointIndex!].xData ==
                                      "Inactive") {
                                    // widget.parent!.setState(() {
                                    //   Util.selectedIndex = 2;
                                    //   objectFilter  = 4;
                                    // });
                                  } else if (dataMap[val.pointIndex!].xData ==
                                      "No Data") {
                                    // widget.parent!.setState(() {
                                    //   Util.selectedIndex = 2;
                                    //   objectFilter  = 5;
                                    // });
                                  } else if (dataMap[val.pointIndex!].xData ==
                                      "Offline") {
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
                            Text("بدون بيانات",
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
          )),
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
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
            gradient: LinearGradient(
              colors: [
                Color(0xffff6e02),
                Color(0xffffff00) /*, Color(0xffff6d00)*/
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
                  StaticVarMethod.notificationback = false;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()),
                  );
                  print("TotalAlerts");
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xff962bb4),
                    Color(0xff5467d8),
                    Color(0xff2394f3)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(
                    onTap: () {
                      StaticVarMethod.eventList = _geofencealets;
                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                      print("Geofence");
                    },
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xffe84842),
                    Color(0xff5467d8),
                    Color(0xff2394f3)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(

                    onTap: () {
                      StaticVarMethod.eventList = _overspeedalets;
                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                      print("Overspeed");
                    },
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xffa2969a),
                    Color(0xffc36080),
                    Color(0xffe62666)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(

                    onTap: () {
                      StaticVarMethod.eventList = _idlealets;

                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                      print("Excess Idle");
                    },
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xff7a11f5),
                    Color(0xff5467d8),
                    Color(0xff010f1c)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(

                    onTap: () {
                      StaticVarMethod.eventList = _stopalets;

                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                      print("Parked");
                    },
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xff9fff0e),
                    Color(0xff5467d8),
                    Color(0xfff8d000)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(
                    onTap: () {
                      StaticVarMethod.eventList = _ignitiononalets;
                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );

                      print("Ignition On");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.key,
                          color: Colors.white,
                          size: 25,
                        ),
                        // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                        Text("تشغيل المحرك".tr + " ",
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xffe84842),
                    Color(0xff00ff80),
                    Color(0xff74ff00)
                  ],
                  begin: FractionalOffset.centerLeft,
                  end: FractionalOffset.centerRight,
                ),
              ),
              child:
                  GestureDetector(
                    onTap: () {
                      StaticVarMethod.eventList = _ignitionoffalets;

                      StaticVarMethod.notificationback = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage()),
                      );
                      print("Ignition Off");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.key_off,
                          color: Colors.white,
                          size: 25,
                        ),
                        // icon: Image.asset(AssetsRes.WARNING, width: 25,),
                        Text("ايقاف المحرك".tr + " ",
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

  Widget loadEventsData() {
    return InkWell(
      onTap: () {
        StaticVarMethod.notificationback = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
      },
      child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AssetsRes.WARNING,
                width: 60,
              ),
              Text(
                'Alerts : ' + eventList.length.toString(),
                style: TextStyle(
                    color: MyColor.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
  }

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

  Widget fleetIdle() {
    return Card(
        child: Container(
            padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
            alignment: Alignment.centerLeft,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ('fleetIdle').tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                ])));
  }

  Widget maintenanceReminder() {

    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => serviceslistscreen()),
          );

          //  Navigator.pushNamed(context, "/maintenanceReminder");
        },
        child: Card(
            child: Container(
                padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مواعيد الصيانة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      loadMaintenanceData()
                    ]))));
  }

  Widget loadMaintenanceData() {

    StaticVarMethod.devicelist=_allVehicles;
    StaticVarMethod.serviceslist=[];
    var count=0;
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      deviceItems model = StaticVarMethod.devicelist.elementAt(i);
      if(model.services != null && model.services!.length > 0){
        for (int i = 0; i < model.services!.length; i++) {
          Services model1 = model.services!.elementAt(i);
          if(model1.value!.contains("expire") && model1.expiring==true){
            services_model smodel=new services_model();
            smodel.id=model1.id;
            smodel.name=model1.name;
            smodel.value=model1.value;
            smodel.devicename=model.deviceData!.name.toString();
            smodel.imei=model.deviceData!.imei.toString();
            StaticVarMethod.serviceslist.add(smodel);
            count++;
          }

        }

      }
    }

    print(StaticVarMethod.serviceslist);
    print(StaticVarMethod.serviceslist);
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            AssetsRes.MAINTENANCE_REMINDER,
            width: 50,
          ),
          Text(
            'مواعيد الصيانة : ' + count.toString(),
            style: TextStyle(
                color: MyColor.primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget RenewalReminder() {
    return InkWell(
        onTap: () {
          StaticVarMethod.expirelist = _expiredVehicles;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => expirelistscreen()),
          );
        },
        child: Card(
            child: Container(
                padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التجديد',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      loadReminderData()
                    ]))));
  }

  Widget Precautions() {
    return Card(
        child: Container(
            padding: EdgeInsets.only(top: 10, left: 10, bottom: 5),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Text(
                    '!انتبا',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  )),
                  Divider(),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      child: Text(
                        'ٹریکر موٹر انشورنس کا متبادل نہیں ہے اور نہ ہی چوری روکنے کا آلہ ہے گاڑی چوری ہونے کی صورت میں کمپنی ذمہ دار نہیں ہوگی',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ])));
  }

  Widget loadReminderData() {
    // List<dynamic> devices = [];

    // objectStore.objectSettings.forEach((key, value) {
    //   if(value[33] != "0000-00-00"){
    //     DateTime now = DateTime.now();
    //     DateTime date =  DateTime.parse(value[33].toString());
    //     if(now.isAfter(date)){
    //       devices.add(value);
    //     }
    //   }
    // });

    return InkWell(
      onTap: () {
        StaticVarMethod.expirelist = _expiredVehicles;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => expirelistscreen()),
        );
      },
      child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                AssetsRes.CARD,
                width: 60,
              ),
              Text(
                'التجديد للمركبة: ' + _expiredVehicles.length.toString(),
                style: TextStyle(
                    color: MyColor.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.text, this.color);
  final String xData;
  final num yData;
  final String text;
  final Color color;
}
