import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:maktrogps/bloc/kmandfuelhistory/bloc/kmandfuelhistory_bloc.dart';
import 'package:maktrogps/config/apps/images.dart';
import 'package:maktrogps/config/constant.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/data/model/loginModel.dart';
import 'package:maktrogps/data/model/product_model.dart';

import 'package:maktrogps/data/screens/historyscreen.dart';
import 'package:maktrogps/data/screens/livetrackoriginal.dart';
import 'package:maktrogps/data/screens/mainmapscreenoriginal.dart';
import 'package:maktrogps/data/screens/notificationscreen.dart';
import 'package:maktrogps/data/screens/optionsscreen/alloptions.dart';
import 'package:maktrogps/data/screens/playback.dart';
import 'package:maktrogps/data/screens/playbackscreen.dart';
import 'package:maktrogps/data/screens/playbackselection.dart';
import 'package:maktrogps/data/screens/reports/reportselection.dart';
import 'package:maktrogps/data/screens/reports/vehicle_info.dart';
import 'package:maktrogps/data/screens/task/tasks.dart';
import 'package:maktrogps/data/screens/testscreens/livelocation.dart';
import 'package:maktrogps/data/screens/trip/tripinfoselectionscreen.dart';
import 'package:maktrogps/data/screens/vehicle_dasboard.dart';
import 'package:maktrogps/mapconfig/CustomColor.dart';
import 'package:maktrogps/ui/reusable/cache_image_network.dart';
import 'package:maktrogps/ui/reusable/global_function.dart';
import 'package:maktrogps/ui/reusable/global_widget.dart';
import 'package:maktrogps/ui/reusable/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maktrogps/utils/MapUtils.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import '../../mvvm/view_model/objects.dart';
import 'LiveMapScreen/LiveMapScreen.dart';
import 'commands/CommandWindow.dart';
import 'livetrack.dart';
import 'lockscreen.dart';
import 'lockscreenNew.dart';
import 'reports/kmdetail.dart';

class listscreencentereasytracking extends StatefulWidget {
  @override
  _listscreencentereasytracking createState() => _listscreencentereasytracking();
}

class _listscreencentereasytracking extends State<listscreencentereasytracking>
    with SingleTickerProviderStateMixin {
  // initialize global function and global widget
  final _globalFunction = GlobalFunction();
  final _globalWidget = GlobalWidget();
  final _shimmerLoading = ShimmerLoading();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PersistentBottomSheetController? _bottomSheetController;

  String filtertext = "All";
  bool _loading = true;

  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> markers = new Set();

  Color _color1 = Color(0xff777777);
  Color _color2 = Color(0xFF515151);
  Color _topSearchColor = Colors.white;
  List<deviceItems> _vehiclesData = [];
  List<deviceItems> _vehiclesData_sorted = [];
  List<deviceItems> _vehiclesData_duplicate = [];
  // _listKey is used for AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  TextEditingController _etSearch = TextEditingController();
  bool _trafficEnabled = false;
  bool _batterycharging = false;
  bool _lock = false;
  bool _wifi = false;
  bool _lowbattery = false;
  bool _gpsconnected = true;
  var _trafficButtonColor = Colors.green[700];

  int _tabIndex = 0;

  GoogleMapController? _controller;
  bool _mapLoading = true;
  static Color primaryDark = const Color.fromARGB(255, 13, 61, 101);
  double _currentZoom = 14;

//  final LatLng _initialPosition = LatLng(-6.168033, 106.900467);

  Marker? _marker;

  late BitmapDescriptor _markerDirection;
  void _setSourceAndDestinationIcons() async {
    _markerDirection = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/direction.png');
  }

  List<String> carstatusList = [
    'AllVehicle'.tr,
    'Running'.tr,
    'Stopped'.tr,
    'Idle'.tr,
    'Offline'.tr,
    'InActive'.tr,
    'Expired'.tr
  ];
  int starIndex = 0;
  Color CHARCOAL = Color(0xFF515151);
  bool _searchEnabled = false;
  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _offlineVehicles = [];
  List<deviceItems> _stoppedVehicles = [];
  List<deviceItems> _expiredVehicles = [];
  late SharedPreferences prefs;
  late ObjectStore objectStore;

  // KmandfuelHistoryBloc kmhistorybloc = KmandfuelHistoryBloc();
  @override
  void initState() {
    // kmhistorybloc.add(KmandfuelHistoryInitialFetchEvent());
    checkPreference();
    _setSourceAndDestinationIcons();
    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _etSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // StaticVarMethod.devicelist.clear();
    objectStore = Provider.of<ObjectStore>(context);
    _vehiclesData = objectStore.objects;
    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    _expiredVehicles = [];
    _offlineVehicles = [];

    if (_vehiclesData.isNotEmpty) {
      _vehiclesData_duplicate.clear();
      _vehiclesData_sorted.clear();
      _vehiclesData_sorted.addAll(_vehiclesData);

      if (filtertext != "All") {
        for (int i = 0; i < _vehiclesData_sorted.length; i++) {
          deviceItems model = _vehiclesData_sorted.elementAt(i);

          String other = model.deviceData!.traccar!.other.toString();
          String ignition = "false";
          String stopDuration = model.stopDuration.toString();
          int hours = 0;
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
            String result = stopDuration.substring(0, endIndex);
            hours = int.parse(result);
            print(result);
          }

          if (filtertext == "Offline") {
            // if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
            if (model.online.toString().contains("offline") &&
                !model.time.toString().contains("Not connected") &&
                !model.time.toString().contains("Expired")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('Offline');
            }
          } else if (filtertext == "Idle") {
            if (ignition.contains("true") &&
                !model.online.toString().contains("offline") &&
                double.parse(model.speed.toString()) < 1.0) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('Idle');
            }
          } else if (filtertext == "In Active") {
            if (model.online.toString().toLowerCase().contains("offline") &&
                model.time.toString().toLowerCase().contains("not connected")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('In Active');
            }
          } else if (filtertext == "Running") {
            if (model.online.toString().toLowerCase().contains("online")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('online');
            }
          } else if (filtertext == "Stopped") {
            if (ignition.contains("false") &&
                model.time.toString().toLowerCase() != "not connected") {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('stoppedvehile');
            }
          } else if (filtertext == "expire") {
            if (model.time.toString().toLowerCase().contains("expire")) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('expire');
            }
          } else {
            if (model.name.toString().toLowerCase().contains(filtertext
                .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
            ) {
              _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
              print('item exists');
            }
          }
        }
      } else {
        _vehiclesData_duplicate.addAll(_vehiclesData);
      }

      StaticVarMethod.devicelist = _vehiclesData;

      for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
        deviceItems model = StaticVarMethod.devicelist.elementAt(i);
        String other = model.deviceData!.traccar!.other.toString();
        String stopDuration = model.stopDuration.toString();
        String ignition = "false";
        int hours = 0;
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
        if (model.online.toString().contains("offline") &&
            !model.time.toString().contains("Not connected") &&
            !model.time.toString().contains("Expired")) {
          _offlineVehicles.add(StaticVarMethod.devicelist.elementAt(i));
          print('offline');
        } else if (model.time.toString().toLowerCase().contains("expire")) {
          _expiredVehicles.add(StaticVarMethod.devicelist.elementAt(i));
          print('expire');
        } else if (ignition.contains("true") &&
            !model.online.toString().contains("offline") &&
            double.parse(model.speed.toString()) < 1.0) {
          _idleVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (model.online.toString().toLowerCase().contains("offline") &&
            model.time.toString().toLowerCase().contains("not connected")) {
          _inactiveVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (model.online.toString().toLowerCase().contains("online")) {
          _runningVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        } else if (ignition.contains("false") &&
            model.time.toString().toLowerCase() != "not connected") {
          _stoppedVehicles.add(StaticVarMethod.devicelist.elementAt(i));
        }
      }

      _loading = false;
    } else {
      print("not available");
      _loading = false;
      _vehiclesData_duplicate.clear();
      _vehiclesData_sorted.clear();
    }

    final double boxImageSize = (MediaQuery.of(context).size.width / 12);
    print("list Builder");
    Widget? _child;
    if (_loading == true) {
      _child = const Center(child: CircularProgressIndicator());
    } else if (_vehiclesData_duplicate.isNotEmpty) {
      _child = new RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : devicesListwidget(boxImageSize),
      );
    } else if (_vehiclesData_duplicate.isEmpty) {
      _child = new RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : Container(),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: (_searchEnabled)
            ? Container(
          child: TextFormField(
            controller: _etSearch,
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800 /*Colors.white*/),
            onChanged: (value) {
              setState(() {
                print('text changed');
                if (value.isNotEmpty) {
                  filterSearchResults(value);
                } else {
                  _vehiclesData.clear();
                  filtertext = "All";
                  // setState(() {
                  //_getData();
                  print("full list");
                  print(_vehiclesData.length);
                  //  });
                }
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.transparent,
              filled: true,
              hintText: 'Enter device name or IMEI'.tr,
              hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800 /*Colors.white*/),
              prefixIcon: Icon(Icons.search,
                  color: Colors.black /*Colors.white*/, size: 18),
              suffixIcon: (_etSearch.text == '')
                  ? null
                  : GestureDetector(
                  onTap: () {
                    filtertext = "All";
                    //setState(() {
                    //_getData();
                    _etSearch = TextEditingController(text: '');
                    _searchEnabled =
                    _searchEnabled == false ? true : false;
                    //  });
                  },
                  child: Icon(Icons.close,
                      color: Colors.grey[500], size: 16)),
              focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        )
            : Image.asset(Images.appBarLogoNew, height: 40),/*Center(child: Text("List of Vehicles")),*/ /*Image.asset(
            StaticVarMethod.listimageurl,
            height: 40),*/
        // backgroundColor: themeDark,
        backgroundColor: Colors.grey.shade50,
        bottom: PreferredSize(
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1.0,
                      )),
                  color: Colors.grey.shade200),
              padding: EdgeInsets.fromLTRB(5, 5, 10, 10),
              // margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              height: 90,
              child: ListView(
                //padding: EdgeInsets.all(16),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(carstatusList.length, (index) {
                        return radioStar(carstatusList[index], index);
                      }),
                    ),
                  ),
                ],
              )),
          preferredSize: Size.fromHeight(90),
        ),
        actions: [
          IconButton(
              icon: Icon(
                (_searchEnabled) ? Icons.clear_rounded : Icons.search,
                color: Colors.grey.shade800 /*Colors.white*/,
                size: 35,
              ),
              onPressed: () {
                setState(() {
                  filtertext = "All";
                  //setState(() {
                  // _getData();
                  _etSearch = TextEditingController(text: '');
                  _searchEnabled = _searchEnabled == false ? true : false;
                });
              }),
        ],
      ),
      body: _child,
    );
  }

  Widget radioStar(String txt, int index) {
    Color statuscolor = Colors.white;
    Color iconcolor = Color(0xffA01490);
    var txt1 = "(0)";
    if (index == 0) {
      txt = txt;
      txt1 = _vehiclesData.length.toString();
      iconcolor = Color(0xffA01490);
    } else if (index == 1) {
      statuscolor = Colors.green.shade100;
      txt = txt;
      txt1 = _runningVehicles.length.toString();
      iconcolor = Color(0xff40d30f);
    } else if (index == 2) {
      statuscolor = Colors.red.shade100;
      txt = txt;
      txt1 = _stoppedVehicles.length.toString();
      iconcolor = Colors.red;
    } else if (index == 3) {
      statuscolor = Colors.yellow.shade100;
      txt = txt;
      txt1 = _idleVehicles.length.toString();
      iconcolor = Color(0xffffda07);
    } else if (index == 4) {
      statuscolor = Colors.blue.shade100;
      txt = txt;
      txt1 = _offlineVehicles.length.toString();
      iconcolor = Colors.blue;
    } else if (index == 5) {
      statuscolor = Colors.grey.shade300;

      txt = txt;
      txt1 = _inactiveVehicles.length.toString();
      iconcolor = Colors.grey.shade900;
    } else if (index == 6) {
      statuscolor = Colors.grey.shade100;
      txt = txt;
      txt1 = _expiredVehicles.length.toString();
      iconcolor = Colors.grey;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          starIndex = index;
          _tabIndex = index;
          if (index == 0) {
            filterSearchResults("All");
          } else if (index == 1) {
            filterSearchResults("Running");
          } else if (index == 2) {
            filterSearchResults("Stopped");
          } else if (index == 3) {
            filterSearchResults("Idle");
          } else if (index == 4) {
            filterSearchResults("Offline");
          } else if (index == 5) {
            filterSearchResults("In Active");
          } else if (index == 6) {
            filterSearchResults("expire");
          }
        });
        // Fluttertoast.showToast(
        //     msg: 'Click TabBar', toastLength: Toast.LENGTH_SHORT);
        print('idx : ' + _tabIndex.toString());
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5, 15, 0, 10),
            padding: EdgeInsets.only(bottom: 5),
            height: 55,
            width: 57,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                  )
                ],
              //  color: Color(0xffEFEDF8),
                color: iconcolor.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                  topRight: Radius.circular(5),
                  topLeft: Radius.circular(5),
                )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(txt1,
                    style: TextStyle(
                        color: starIndex == index ? Colors.blue : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 5,
                ),
                Text(txt,
                    style: TextStyle(
                      color: starIndex == index ? Colors.blue : Colors.white,
                      fontSize: 10,
                    ))

              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          //   child: Container(
          //     margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
          //     height: 35,
          //     width: 35,
          //     decoration: BoxDecoration(
          //         color: iconcolor.withOpacity(0.4),
          //         borderRadius: BorderRadius.only(
          //           bottomLeft: Radius.circular(100),
          //           bottomRight: Radius.circular(100),
          //           topRight: Radius.circular(100),
          //           topLeft: Radius.circular(100),
          //         )),
          //     child: Container(
          //       margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
          //       padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
          //       height: 17,
          //       width: 17,
          //       decoration: BoxDecoration(
          //           boxShadow: [
          //             BoxShadow(
          //               color: Color(0xff477d78), //.withOpacity(0.6),
          //               blurRadius: 15,
          //             )
          //           ],
          //           color: iconcolor,
          //           borderRadius: BorderRadius.only(
          //             bottomLeft: Radius.circular(100),
          //             bottomRight: Radius.circular(100),
          //             topRight: Radius.circular(100),
          //             topLeft: Radius.circular(100),
          //           )),
          //       child: Image(
          //         image: AssetImage(
          //           'assets/tbtrack/carup.png',
          //         ),
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),

    );
  }


  Widget devicesListwidget(double boxImageSize) {
    return ScrollablePositionedList.builder(
      key: _listKey,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 120),
      itemCount: _vehiclesData_duplicate.length,
      itemBuilder: (context, index) =>
          _buildItem(_vehiclesData_duplicate[index], boxImageSize, index),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
    /*AnimatedList(
      key: _listKey,
      initialItemCount: _vehiclesData_duplicate.length,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        return _buildItem(_vehiclesData_duplicate[index], boxImageSize, animation, index);
      },
    );*/
  }

  void filterSearchResults(String query) {
    filtertext = query;
    print("inside filter");
    _vehiclesData_duplicate.clear();
    if (query.isNotEmpty && query != "All") {
      for (int i = 0; i < _vehiclesData_sorted.length; i++) {
        deviceItems model = _vehiclesData_sorted.elementAt(i);

        String other = model.deviceData!.traccar!.other.toString();
        String ignition = "false";
        String stopDuration = model.stopDuration.toString();
        int hours = 0;
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
          String result = stopDuration.substring(0, endIndex);
          hours = int.parse(result);
          print(result);
        }

        if (filtertext == "Offline") {
          //  if (hours>23 && ignition.contains("false")) {
          // if (model.online.toString().toLowerCase().contains("offline") && !model.time.toString().toLowerCase().contains("Not connected") && !model.time.toString().toLowerCase().contains("Expired")/*hours>23 */&& ignition.contains("false")) {
          if (model.online.toString().contains("offline") &&
              !model.time.toString().contains("Not connected") &&
              !model.time.toString().contains("Expired")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Offline');
          }
        } else if (query == "Idle") {
          if (ignition.contains("true") &&
              !model.online.toString().contains("offline") &&
              double.parse(model.speed.toString()) < 1.0) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Idle');
          }
        } else if (filtertext == "In Active") {
          if (model.online.toString().toLowerCase().contains("offline") &&
              model.time.toString().toLowerCase().contains("not connected")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Offline');
          }
        } else if (query == "Running") {
          if (model.online.toString().toLowerCase().contains("online")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Running');
          }
        } else if (query == "Stopped") {
          if (ignition.contains("false") &&
              model.time.toString().toLowerCase() != "not connected") {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('Stopped');
          }
        } else if (query == "expire") {
          if (model.time.toString().toLowerCase().contains("expire")) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('expire');
          }
        } else {
          if (model.name.toString().toLowerCase().contains(query
              .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
          ) {
            _vehiclesData_duplicate.add(_vehiclesData_sorted.elementAt(i));
            print('item exists');
          }
        }
      }

      setState(() {});
    } else {
      if (query == "All") {
        _vehiclesData_duplicate.addAll(_vehiclesData_sorted);
        print('All');
      }
    }
  }

  Color randomColor() =>
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  Widget _buildItem(deviceItems productData, boxImageSize, index) {
    double imageSize = MediaQuery.of(context).size.width / 25;
    double lat = productData.lat!.toDouble();
    double lng = productData.lng!.toDouble();
    double course = productData.course!.toDouble();
    int speed = productData.speed!.toInt();
    String imei = productData.deviceData!.imei.toString();
    String carstatus = productData.online!.toString();
    String time = productData.time.toString();
    String drivername = productData.driverData!.name.toString();
    Color statuscolor = Color(0xffBBDEFA);
    // if (speed > 0) {
    //   statuscolor = Color(0xff9E9E9E);
    // } else {
    //   statuscolor = Color(0xffBBDEFA);
    // }
    String other = productData.deviceData!.traccar!.other.toString();
    String ignition = "false";
    String enginehours = "0h";
    String sat = "0";
    String totaldistance = "0";
    int batterylevel = 0;
    int gsm = 0;
    String distance = "0";
    String devicestatus = "0";
    String stopDuration = productData.stopDuration.toString();
    int hours = 0;
    if (other.contains("<ignition>")) {
      const start = "<ignition>";
      const end = "</ignition>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      ignition = other.substring(startIndex + start.length, endIndex);
    }

    if (other.contains("<batterylevel>")) {
      const start = "<batterylevel>";
      const end = "</batterylevel>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
       batterylevel =
      int.parse(other.substring(startIndex + start.length, endIndex));
    }
    if (other.contains("<rssi>")) {
      const start = "<rssi>";
      const end = "</rssi>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
       gsm =
      int.parse(other.substring(startIndex + start.length, endIndex));
    }
    if (other.contains("<enginehours>")) {
      const start = "<enginehours>";
      const end = "</enginehours>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      int hours =
      int.parse(other.substring(startIndex + start.length, endIndex));
      enginehours = (hours / 3600).toStringAsFixed(2);
    }
    if (other.contains("<sat>")) {
      const start = "<sat>";
      const end = "</sat>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      sat = other.substring(startIndex + start.length, endIndex);
    }
    if (other.contains("<totaldistance>")) {
      const start = "<totaldistance>";
      const end = "</totaldistance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      double dis =
      double.parse(other.substring(startIndex + start.length, endIndex));
      totaldistance = (dis / 1000).toStringAsFixed(2);
      // totaldistance = other.substring(startIndex + start.length, endIndex);
    }
    if (other.contains("<distance>")) {
      const start = "<distance>";
      const end = "</distance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      distance = other.substring(startIndex + start.length, endIndex);
    }

   // String iconpath = 'assets/tbtrack/truck_sidestop.png';
     String iconpath = 'assets/tbtrack/truck_sidestop.png';

    if (stopDuration.toString().contains("h")) {
      const end = "h";
      final endIndex = stopDuration.indexOf(end);
      //String h = stopDuration.substring(endIndex);
      String result = stopDuration.substring(0, endIndex);
      hours = int.parse(result);
      print(result);
      // print(h);
    }

    // if (hours >23 && ignition.contains("false")) {
    // if (productData.online.toString().contains("offline") && !productData.time.toString().contains("Not connected") && !productData.time.toString().contains("Expired")) {
    if (productData.online.toString().contains("offline") &&
        !productData.time.toString().contains("Not connected") &&
        !productData.time.toString().contains("Expired")) {
      iconpath = 'assets/tbtrack/truck_sideinactive.png';
      devicestatus = "NotConnected".tr;
      statuscolor =  Colors.blue.withOpacity(0.1);
      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sideinactive.png";
    } else if (productData.time!.contains('Not connected')) {
      iconpath = 'assets/tbtrack/truck_sidenodata.png';
      devicestatus = "Not connected";
      statuscolor = Colors.black12.withOpacity(0.1);
      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sidenodata.png";
    } else if (productData.speed!.toInt() > 0) {
      iconpath = 'assets/tbtrack/truck_siderunning.png';
      devicestatus = "Moving";
      statuscolor =  Colors.green.withOpacity(0.1);
      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "siderunning.png";
    } else if (ignition.contains("true") &&
        !productData.online.toString().contains("offline") &&
        double.parse(productData.speed.toString()) < 1.0) {
      iconpath = 'assets/tbtrack/truck_sideidle.png';
      devicestatus = "Idle";
      statuscolor =  Colors.yellow.withOpacity(0.1);
      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sideidle.png";
    } else if (productData.online!.contains('online')) {
      iconpath = 'assets/tbtrack/truck_siderunning.png';
      devicestatus = "Online";

      statuscolor =  Colors.green.withOpacity(0.1);
      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "siderunning.png";
    } else {
      iconpath = 'assets/tbtrack/truck_sidestop.png';

      devicestatus = "Stopped";
      statuscolor =  Colors.red.withOpacity(0.2);


      if (StaticVarMethod.pref_static!
          .get(productData.deviceData!.imei.toString()) !=
          null)
        iconpath = "assets/tbtrack/" +
            StaticVarMethod.pref_static!
                .get(productData.deviceData!.imei.toString())
                .toString() +
            "sidestop.png";
    }

    // <info><event>0</event><sat>13</sat><hdop>0.9</hdop><odometer>678030</odometer>
    // <status>61</status><ignition>false</ignition><input>0</input><output>0</output>
    // <power>12.51</power><battery>4.07</battery><adc2>0</adc2><adc3>0</adc3><sequence>80</sequence>
    // <distance>0</distance><totaldistance>639240.95</totaldistance><motion>false</motion>
    // <valid>true</valid><enginehours>51916</enginehours><gsmsignal>13</gsmsignal></info>

    return GestureDetector(
        onTap: () {
          StaticVarMethod.deviceName = productData.name.toString();
          StaticVarMethod.deviceId = productData.id.toString();
          StaticVarMethod.imei = productData.deviceData!.imei.toString();
          StaticVarMethod.simno = productData.deviceData!.simNumber.toString();
          StaticVarMethod.lat = productData.lat!.toDouble();
          StaticVarMethod.lng = productData.lng!.toDouble();
          StaticVarMethod.devicestatus = devicestatus;
          StaticVarMethod.devicestatuscolor = statuscolor;



          Navigator.push(
            context,
            MaterialPageRoute(
              //  builder: (context) => livetracknew()),
                builder: (context) => LiveMapScreen()),
          );
          // showModalBottomSheet<void>(
          //   context: context,
          //   //isDismissible: false,
          //   //barrierColor: Colors.transparent,
          //   backgroundColor: Colors.transparent,
          //   builder: (BuildContext context) {
          //     return Container(
          //       //color: Colors.transparent,
          //         height: MediaQuery.of(context).size.height / 3.8,
          //         child: _showbottomPopup());
          //   },
          // );
          //Fluttertoast.showToast(msg: 'Click ${productData.name}', toastLength: Toast.LENGTH_SHORT);
        },
        child: Stack(
          children: [

             Container(
               decoration: BoxDecoration(
                 color: statuscolor,
                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
               ),
               padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
               margin: EdgeInsets.only(left: 10,bottom: 8,right: 10,top: 0),

                 child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10,bottom: 0,right: 0,top: 0),
                            //color: Colors.red,
                            child: Row(
                                children:[
                                  Image.asset("assets/images/redcircle.png",
                                    height: 13,width: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '' + productData.deviceData!.name.toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                            ),

                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Row(
                              children: [
                                Text(
                                  "الحالة : "+devicestatus.tr,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: 8,left: 10),
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                //color: Colors.red,
                                borderRadius:
                                BorderRadius.all(Radius.circular(0)),
                              ),
                              child: Image.asset(iconpath,
                                  height: 80, width: 80)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                            height: 70,
                            width: 130,
                            //color:Colors.yellowAccent,
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    // margin: const EdgeInsets.fromLTRB(0, 11, 0, 5),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/tbtrack/clock.png",
                                            height: 12,
                                            width: 12,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            ' '.tr,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(productData.time.toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  // Container(
                                  //     margin: const EdgeInsets.fromLTRB(
                                  //         0, 5, 0, 0),
                                  //     child: Row(
                                  //       children: [
                                  //         Image.asset(
                                  //           "assets/tbtrack/totalicon.png",
                                  //           height: 12,
                                  //           width: 12,
                                  //           color: Colors.grey,
                                  //         ),
                                  //         Text(
                                  //           ' Odo'.tr,
                                  //           style: TextStyle(
                                  //             fontSize: 11,
                                  //             color: Colors.black,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),
                                  //         ),
                                  //         Text(
                                  //           totaldistance+' km',
                                  //           style: TextStyle(
                                  //             fontSize: 11,
                                  //             fontWeight: FontWeight.bold,
                                  //             height: 0,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     )
                                  // ),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 5, 0, 0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/tbtrack/clock.png",
                                            height: 12,
                                            width: 12,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            ' '.tr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('since:'+
                                            productData.stopDuration.toString(),
                                            style: TextStyle(
                                              fontSize: 8,
                                              //fontWeight: FontWeight.bold,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      )),
                                  // Container(
                                  //     margin: const EdgeInsets.fromLTRB(
                                  //         0, 5, 0, 0),
                                  //     child: Row(
                                  //       children: [
                                  //         Container(
                                  //           margin: EdgeInsets.only(right: 3),
                                  //           padding: EdgeInsets.all(1.5),
                                  //           width: 13,
                                  //           height: 13,
                                  //           decoration: BoxDecoration(
                                  //             color: ( Colors.transparent),
                                  //             border: Border.all(width: 1,
                                  //                 color: Colors.grey,),
                                  //             borderRadius: BorderRadius.all(Radius.circular(30)),
                                  //
                                  //           ),
                                  //           // color: Colors.white,
                                  //           //color: Color(0x99FFFFFF),
                                  //           child:Image.asset(
                                  //             "assets/tbtrack/driver.png",
                                  //             height: 12,
                                  //             width: 12,
                                  //             color: Colors.grey,
                                  //           ),
                                  //         ),
                                  //
                                  //         Text(
                                  //           "Driver : ",
                                  //           style: TextStyle(
                                  //             fontSize: 11,
                                  //             color: Colors.black,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),
                                  //         ),
                                  //         Text(drivername,
                                  //           style: TextStyle(
                                  //             fontSize: 9,
                                  //             color: Colors.black,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),),
                                  //       ],
                                  //     ),),
                                ]),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 6,right: 20),
                            padding: EdgeInsets.all(5),
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: ( Colors.white),
                              border: Border.all(width: 0.5,
                                  color: Colors.grey[400]!.withOpacity(0.4)),
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.8),
                                  blurRadius: 6.0,
                                  //offset: const Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                            // color: Colors.white,
                            //color: Color(0x99FFFFFF),
                            child:Column(
                              children: [
                                Text('' + productData.speed.toString() + '', style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.w600,fontSize: 18,
                                )
                                ),
                                SizedBox(height: 0),
                                Text('Km/h', style: TextStyle(
                                  color: Colors.black, fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                )
                                ),
                                // Text('mp/h', style: TextStyle(
                                //   color: Colors.black, fontWeight: FontWeight.w400,
                                //   fontSize: 12,
                                // )
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10,bottom: 0,right: 0,top: 0),
                           /* height: 20,
                              width: 250,*/
                           // color: Colors.red,
                              child: Row(
                               mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/images/placeholder.png",
                                    height: 11,
                                    width: 11,
                                    color: Colors.black,
                                  ),
                                 // SizedBox(width: 5,),
                                  addressLoad(lat.toString(), lng.toString()),
                                ],
                              )
                          ),
                      // Container(
                      //   margin: EdgeInsets.only(left: 10,bottom: 0,right: 10,top: 0),
                      //   child:
                      //   Row(
                      //     mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                      //     children: [
                      //       Text(
                      //         "IMEI:"+productData.deviceData!.imei.toString(),
                      //         style: TextStyle(
                      //           fontSize: 11,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.black,
                      //         ),
                      //       ),
                      //       Text(
                      //         "Expiry : "+productData.deviceData!.expirationDate.toString(),
                      //         style: TextStyle(
                      //           fontSize: 11,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                         margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                         height: 3,
                             // width: 250,
                         color: Color(0xffC9D5D0),
                          child: Row(

                            children: [

                            ],
                          )
                      ),
                      /*Container(
                        height:30,
                        width: 340,
                        //color:Colors.blue,
                        margin: EdgeInsets.only(left: 10,right: 10,bottom: 5),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(left: 5,),
                                child: Row(
                                  children: [
                                    (ignition.contains("true") || speed >0)?
                                    Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.green)
                                        :Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.red),
                                    SizedBox(width: 5,),
                                    (ignition.contains("true") || speed >0)?
                                    Text("Key",style: TextStyle(
                                        color:Colors.green,fontSize: 10),
                                    ):Text("Key",style: TextStyle(
                                        color:Colors.red,fontSize: 10),
                                    ),
                                  ],
                                )

                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                child: Row(
                                  children: [
                                    (gsm >=3)?
                                    Image.asset("assets/tbtrack/sattelite2.png",height: 15,width: 15,color:Colors.green)
                                        :Image.asset("assets/tbtrack/sattelite2.png",height: 15,width: 15,color:Colors.red),
                                    SizedBox(width: 5,),
                                    (gsm >=3)?
                                    Text("GPS",style: TextStyle(
                                        color:Colors.green,fontSize: 10),
                                    ):Text("GPS",style: TextStyle(
                                        color:Colors.red,fontSize: 10),
                                    ),
                                  ],
                                )

                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                child:   Row(
                                  children: [
                                    (batterylevel >= 3)?
                                    Image.asset("assets/tbtrack/battery1.png",height: 15,width: 15,color:Colors.green)
                                        :Image.asset("assets/tbtrack/battery1.png",height: 15,width: 15,color:Colors.red),
                                    SizedBox(width: 5,),
                                    (batterylevel >= 3)?
                                    Text("PWR",style: TextStyle(
                                        color:Colors.green,fontSize: 10),
                                    ):Text("PWR",style: TextStyle(
                                        color:Colors.red,fontSize: 10),
                                    ),
                                  ],
                                )


                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                child:   Row(
                                  children: [
                                    (gsm >=3)?
                                    Image.asset("assets/tbtrack/signal.png",height: 15,width: 15,color:Colors.green)
                                        :Image.asset("assets/tbtrack/signal.png",height: 15,width: 15,color:Colors.red),
                                    SizedBox(width: 5,),
                                    (gsm >=3)?
                                    Text("GSM",style: TextStyle(
                                        color:Colors.green,fontSize: 10),
                                    ):Text("GSM",style: TextStyle(
                                        color:Colors.red,fontSize: 10),
                                    ),
                                  ],
                                )
                              ),


                            ]
                        ),
                      ),*/
                      (productData.sensors ==null)?
                      Container(
                        height:30,
                        width: 340,
                        //color:Colors.blue,
                        margin: EdgeInsets.only(left: 10,right: 10,bottom: 5),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  height: 18,width: 55,
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                      border: Border.all(width: 0.5, color: Color(
                                          0xff008CA7)),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  padding: EdgeInsets.only(left: 5,),
                                  child: Row(
                                    children: [
                                      (ignition.contains("true") || speed >0)?
                                      Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.green)
                                          :Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.red),
                                      SizedBox(width: 5,),
                                      (ignition.contains("true") || speed >0)?
                                      Text("Key",style: TextStyle(
                                          color:Colors.green,fontSize: 10),
                                      ):Text("Key",style: TextStyle(
                                          color:Colors.red,fontSize: 10),
                                      ),
                                    ],
                                  )

                              ),
                              Container(
                                  height: 18,width: 55,
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                      border: Border.all(width: 0.5, color: Color(
                                          0xff008CA7)),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                  child: Row(
                                    children: [
                                      (gsm >=3)?
                                      Image.asset("assets/tbtrack/sattelite2.png",height: 15,width: 15,color:Colors.green)
                                          :Image.asset("assets/tbtrack/sattelite2.png",height: 15,width: 15,color:Colors.red),
                                      SizedBox(width: 5,),
                                      (gsm >=3)?
                                      Text("GPS",style: TextStyle(
                                          color:Colors.green,fontSize: 10),
                                      ):Text("GPS",style: TextStyle(
                                          color:Colors.red,fontSize: 10),
                                      ),
                                    ],
                                  )

                              ),
                              Container(
                                  height: 18,width: 55,
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                      border: Border.all(width: 0.5, color: Color(
                                          0xff008CA7)),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                  child:   Row(
                                    children: [
                                      (batterylevel >= 3)?
                                      Image.asset("assets/tbtrack/battery1.png",height: 15,width: 15,color:Colors.green)
                                          :Image.asset("assets/tbtrack/battery1.png",height: 15,width: 15,color:Colors.red),
                                      SizedBox(width: 5,),
                                      (batterylevel >= 3)?
                                      Text("PWR",style: TextStyle(
                                          color:Colors.green,fontSize: 10),
                                      ):Text("PWR",style: TextStyle(
                                          color:Colors.red,fontSize: 10),
                                      ),
                                    ],
                                  )


                              ),
                              Container(
                                  height: 18,width: 55,
                                  decoration: BoxDecoration(
                                    //color: Colors.white,
                                      border: Border.all(width: 0.5, color: Color(
                                          0xff008CA7)),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  padding: EdgeInsets.only(right: 0,left: 5,top: 2,bottom: 2),
                                  child:   Row(
                                    children: [
                                      (gsm >=3)?
                                      Image.asset("assets/tbtrack/signal.png",height: 15,width: 15,color:Colors.green)
                                          :Image.asset("assets/tbtrack/signal.png",height: 15,width: 15,color:Colors.red),
                                      SizedBox(width: 5,),
                                      (gsm >=3)?
                                      Text("GSM",style: TextStyle(
                                          color:Colors.green,fontSize: 10),
                                      ):Text("GSM",style: TextStyle(
                                          color:Colors.red,fontSize: 10),
                                      ),
                                    ],
                                  )
                              ),


                            ]
                        ),
                      )
                      /*Container(
                        height:30,
                        width: 340,
                        //color:Colors.blue,
                        margin: EdgeInsets.only(left: 10,right: 10),
                        child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18),
                                child: (ignition.contains("true"))? Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.green):Image.asset("assets/tbtrack/engine.png",height: 15,width: 15,color:Colors.red),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/frozen.png",
                                  height: 15,width: 15,//color:Colors.black38
                                ),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/battery.png",
                                  height: 15,width: 15,//color:Colors.black38
                                ),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/signal.png",
                                    height: 20,width: 20,color:Colors.blue
                                ),
                              ),

                            ]
                        ),
                      )*/:
                      (productData.sensors!.isNotEmpty)?
                      Container(
                        height:40,
                        width: 340,
                        //margin: EdgeInsets.only(left: 10,right: 10),
                        child: ListView.builder(

                            scrollDirection: Axis.horizontal,
                            itemCount: productData.sensors!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8,top: 1),
                                child: Container(
                                   padding: EdgeInsets.all(10),

                                    //height: 18,width: 55,
                                    decoration: BoxDecoration(
                                      //color: Colors.white,
                                        border: Border.all(width: 0.5, color: Color(
                                            0xff008CA7)),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    margin:  EdgeInsets.fromLTRB(0, 10, 0, 0),
                                   // padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                    child:   Row(
                                        children: <Widget>[
                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'ignition'
                                              ? Container(
                                              padding: EdgeInsets.only(right:5),
                                              child: Image.asset("assets/saftyappicon/ignintion.png", height: imageSize,width: imageSize))
                                          // ? Image.asset("assets/sensorsicon/engineon.png", height: imageSize,width: imageSize,color: themeDark,)
                                              :     productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'engine'
                                              ? Image.asset("assets/saftyappicon/ignintion.png", height: imageSize,width: imageSize)
                                              : productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'sat'
                                              ? Container(
                                              padding: EdgeInsets.only(right:5),
                                              child: Image.asset("assets/saftyappicon/sattelite.png", height: imageSize,width: imageSize))
                                              : productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'odometer'
                                              ? Container(
                                              padding: EdgeInsets.only(right:5),
                                              child: Image.asset("assets/saftyappicon/odomenetr.png", height: imageSize,width: imageSize))
                                          //? Image.asset("assets/sensorsicon/speedometeron.png", height: imageSize,width: imageSize)
                                              : productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'battery'
                                              ? Container(
                                              padding: EdgeInsets.only(right:5),
                                              child: Image.asset("assets/saftyappicon/battery.png", height: imageSize,width: imageSize,)):
                                          // Icon(FontAwesomeIcons.batteryFull, size: 16,color:themeDark,) :

                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'charge'
                                              ? Container(
                                              padding: EdgeInsets.only(right:5),
                                              child: Image.asset("assets/saftyappicon/charge_icon.png", height: imageSize,width: imageSize,))
                                          // ? Icon(Icons.battery_charging_full, size: 16,color:themeDark,)
                                              : productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'engine lock'
                                              ? Icon(
                                            Icons.hourglass_bottom_rounded, size: 16,color:themeDark,) :
                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'gps'
                                              ? Icon(
                                            Icons.gps_fixed_outlined, size: 16,color:themeDark,) :
                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'gsm'
                                              ? Container(
                                            padding: EdgeInsets.only(right:5),
                                                child: Image.asset("assets/saftyappicon/gsmicon.png", height: imageSize,
                                                                                            width: imageSize,color: themeDark,),
                                              ):
                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'moving'
                                              ? Icon(Icons.moving_outlined, size: 16,color:themeDark,) :
                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'gps starting km'
                                              ? Icon(
                                            Icons.gps_fixed_outlined, size: 16,color:themeDark,) :

                                          productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'temp'
                                              ? Icon(
                                            FontAwesomeIcons.temperatureLow, size: 16,color:themeDark,)
                                              : productData.sensors![index].type
                                              .toString()
                                              .toLowerCase() ==
                                              'engine_hours'
                                              ? Icon(Icons.alarm, size: 16,color:themeDark,)
                                              : Container(
                                            padding: EdgeInsets.only(right:5),
                                                child: Image.asset("assets/saftyappicon/mileage.png", height: imageSize,
                                                width: imageSize,color: themeDark),
                                              ),
                                          //: Icon(Icons.charging_station, size: 16,color:themeDark,),
                                          //Icon(Icons.engineering,size:imageSize),
                                          // Image.asset("assets/sensorsicon/engineon.png", height: imageSize,width: imageSize),
                                          Text(productData.sensors![index].name.toString(),  style: TextStyle(
                                              fontSize: 7,height: 1.5, color: themeDark)),
                                          Text("${productData.sensors![index].value.toString()}",  style: TextStyle(
                                              fontSize: 7,height: 1, color: themeDark))
                                        ]
                                    )
                                ),
                                //        Column(
                                //   children: [
                                //     Text(productData.sensors![index].name.toString(),
                                //       style: TextStyle(fontSize: 8, color:Colors.grey.shade400,),),
                                //     Text(" : ${productData.sensors![index].value.toString()}",
                                //       style: TextStyle(fontSize: 8,color:Colors.grey.shade400),),
                                //   ],
                                // ),
                              );
                            }),
                      )
                          :Container(
                        height:30,
                        width: 340,
                        margin: EdgeInsets.only(left: 10,right: 10),
                        //color:Colors.blue,
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                            height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18),
                                child:  Image.asset("assets/tbtrack/engine.png",
                                    height: 15,width: 15,color:Colors.red
                                ),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/frozen.png",
                                  height: 15,width: 15,//color:Colors.black38
                                ),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/battery.png",
                                  height: 15,width: 15,//color:Colors.black38
                                ),
                              ),
                              Container(
                                height: 18,width: 55,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                    border: Border.all(width: 0.5, color: Color(
                                        0xff008CA7)),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                padding: EdgeInsets.only(right: 18,left: 0,top: 2,bottom: 2),
                                child:  Image.asset("assets/tbtrack/signal.png",
                                    height: 20,width: 20,color:Colors.blue
                                ),
                              ),

                            ]
                        ),
                      ),

                      /*Container(
                        margin: EdgeInsets.only(left: 0,bottom: 0,right: 0,top: 0),
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _trafficEnabledPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only(
                                        top: 1,
                                        bottom: 1,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.transparent),
                                      ),
                                      // color: Colors.white,
                                      //color: Color(0x99FFFFFF),
                                      child: (!_trafficEnabled)
                                          ? Image.asset(
                                        "assets/tbtrack/engine.png",
                                        height: 15,
                                        width: 15,
                                        color: Colors.red,
                                      )
                                          : Image.asset("assets/tbtrack/engine.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.black26),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _batterychargingPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only(
                                        top: 1,
                                        bottom: 1,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.transparent),
                                      ),
                                      // color: Colors.white,
                                      //color: Color(0x99FFFFFF),
                                      child: (!_batterycharging)
                                          ? Image.asset("assets/tbtrack/frozen.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.red)
                                          : Image.asset("assets/tbtrack/frozen.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.black26),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _lockPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only(
                                        top: 1,
                                        bottom: 1,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.transparent),
                                      ),
                                      // color: Colors.white,
                                      //color: Color(0x99FFFFFF),
                                      child: (!_lock)
                                          ? Image.asset(
                                        "assets/tbtrack/battery.png",
                                        height: 15,
                                        width: 15,
                                        color: Colors.red,
                                      )
                                          : Image.asset(
                                          "assets/tbtrack/battery.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.black26),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _wifiPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only(
                                        top: 1,
                                        bottom: 1,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.transparent),
                                      ),
                                      // color: Colors.white,
                                      //color: Color(0x99FFFFFF),
                                      child: (!_wifi)
                                          ? Image.asset(
                                        "assets/tbtrack/signal.png",
                                        height: 15,
                                        width: 15,
                                        color: Colors.red,
                                      )
                                          : Image.asset("assets/tbtrack/signal.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.black26),
                                    ),
                                  ),
                                   GestureDetector(

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => livetrack()),
                                  );
                                },

                                child: Container(
                                    padding: EdgeInsets.all(2),
                                    margin: EdgeInsets.only(top:5,bottom: 1,left: 5,right: 5,),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Colors.white),
                                    ),
                                    child:   Column(
                                        children: <Widget>[
                                          Image.asset("assets/sensorsicon/Key.png",
                                              height: 15,width: 15,
                                          color: Color(0xff23A24D)),
                                        ]
                                    )
                                ),
                              ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _lowbatteryPressed();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only(
                                        top: 1,
                                        bottom: 1,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                            width: 1, color: Colors.transparent),
                                      ),
                                      // color: Colors.white,
                                      //color: Color(0x99FFFFFF),
                                      child: (!_lowbattery)
                                          ? Image.asset(
                                        "assets/tbtrack/circle.png",
                                        height: 15,
                                        width: 15,
                                        color: Colors.red,
                                      )
                                          : Image.asset("assets/tbtrack/circle.png",
                                          height: 15,
                                          width: 15,
                                          color: Colors.black26),
                                    ),
                                  ),

                                   GestureDetector(

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => livetrack()),
                                  );
                                },

                                child: Container(
                                    padding: EdgeInsets.all(2),
                                    margin: EdgeInsets.only(top:5,bottom: 1,left: 5,right: 5,),
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 1, color: Colors.white),
                                    ),
                                    child:   Column(
                                        children: <Widget>[
                                          Image.asset("assets/sensorsicon/Key.png",
                                              height: 15,width: 15,
                                          color: Color(0xff23A24D)),
                                        ]
                                    )
                                ),
                              ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),*/


                      // _buildGoogleMap(lat,lng,course,imei),
                    ],
                  ),

              ),

          ],
        ));
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficButtonColor =
      _trafficEnabled == false ? Colors.grey[700] : Colors.blue;
    });
  }

  void _batterychargingPressed() {
    setState(() {
      _batterycharging = _batterycharging == false ? true : false;
      _trafficButtonColor =
      _batterycharging == false ? Colors.grey[700] : Colors.blue;
    });
  }

  void _lockPressed() {
    setState(() {
      _lock = _lock == false ? true : false;
      _trafficButtonColor = _lock == false ? Colors.grey[700] : Colors.blue;
    });
  }

  void _wifiPressed() {
    setState(() {
      _wifi = _wifi == false ? true : false;
      _trafficButtonColor = _wifi == false ? Colors.grey[700] : Colors.blue;
    });
  }

  void _lowbatteryPressed() {
    setState(() {
      _lowbattery = _lowbattery == false ? true : false;
      _trafficButtonColor =
      _lowbattery == false ? Colors.grey[700] : Colors.blue;
    });
  }

  Widget _showbottomPopup() {
    double imageSize = MediaQuery.of(context).size.width / 17;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
          return Container(
              margin: EdgeInsets.only(left: 0, right: 0, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),*/
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 12,
                      ),
                      /* width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)
              ),*/
                      child: Text('' + StaticVarMethod.deviceName,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  Container(
                      margin: EdgeInsets.only(top: 12, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        //  builder: (context) => livetracknew()),
                                          builder: (context) => LiveMapScreen()),
                                    );
                                  },
                                  child: Container(
                                    // padding: EdgeInsets.all(8),

                                    // decoration: new BoxDecoration(
                                    //   color: Colors.white,
                                    //   shape: BoxShape.rectangle,
                                    //   borderRadius:BorderRadius.all(Radius.circular(15)),
                                    //   // borderRadius: BorderRadius.circular(8),
                                    //   boxShadow: [
                                    //     BoxShadow(
                                    //       color: Colors.black26,
                                    //       blurRadius: 1.0,
                                    //       //offset: const Offset(0.0, 10.0),
                                    //     ),
                                    //   ],
                                    // ),
                                    // color: Colors.white,
                                    //color: Color(0x99FFFFFF),
                                      child: Column(children: <Widget>[
                                        Image.asset(
                                            "assets/images/movingdurationicon.png",
                                            height: imageSize,
                                            width: imageSize),
                                        Text('LiveMap'.tr,
                                            style: TextStyle(fontSize: 12, height: 2))
                                      ])),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => kmdetail()),
                                    );
                                  },
                                  child: Container(
                                    // padding: EdgeInsets.all(8),

                                    /*  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:BorderRadius.all(Radius.circular(15)),
                                    // borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1.0,
                                        //offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),*/
                                    // color: Colors.white,
                                    //color: Color(0x99FFFFFF),
                                      child: Column(children: <Widget>[
                                        Image.asset(
                                            "assets/images/icons8-bar-chart-100.png",
                                            height: imageSize,
                                            width: imageSize),
                                        Text('Mileage'.tr,
                                            style: TextStyle(fontSize: 12, height: 2.0))
                                      ])),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              playbackselection()),
                                               //playbackwialonnew()),

                                    );
                                  },
                                  child: Container(
                                    //    padding: EdgeInsets.all(8),

                                    /*     decoration: new BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:BorderRadius.all(Radius.circular(15)),
                                    // borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1.0,
                                        //offset: const Offset(0.0, 10.0),
                                      ),
                                    ],
                                  ),*/
                                    // color: Colors.white,
                                    //color: Color(0x99FFFFFF),
                                      child: Column(children: <Widget>[
                                        Image.asset("assets/images/icons8-play-100.png",
                                            height: imageSize, width: imageSize),
                                        Text('Playback'.tr,
                                            style: TextStyle(fontSize: 12, height: 2.0))
                                      ])),
                                ),
                              ],
                            ),
                          ),
                          // Expanded(
                          //   child: Column(
                          //     children: <Widget>[
                          //       GestureDetector(
                          //         onTap: () {
                          //           String url =
                          //               'http://maps.google.com/maps?q=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                          //           launchWhatsApp("11111111111", url);
                          //         },
                          //         child: Container(
                          //           //  padding: EdgeInsets.all(8),
                          //
                          //           /*     decoration: new BoxDecoration(
                          //           color: Colors.white,
                          //           shape: BoxShape.rectangle,
                          //           borderRadius:BorderRadius.all(Radius.circular(15)),
                          //           // borderRadius: BorderRadius.circular(8),
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.black26,
                          //               blurRadius: 1.0,
                          //               //offset: const Offset(0.0, 10.0),
                          //             ),
                          //           ],
                          //         ),*/
                          //           // color: Colors.white,
                          //           //color: Color(0x99FFFFFF),
                          //             child: Column(children: <Widget>[
                          //               Image.asset(
                          //                   "assets/nepalicon/share-location.png",
                          //                   height: imageSize,
                          //                   width: imageSize),
                          //               Text('Share'.tr,
                          //                   style: TextStyle(fontSize: 12, height: 2.0))
                          //             ])),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      )),

                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => reportselection()),
                                  );
                                },
                                child: Container(
                                  //     padding: EdgeInsets.all(8),

                                  /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/images/icons8-bar-chart-100.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('Reports'.tr,
                                          style: TextStyle(fontSize: 12, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => CommandWindowPage()),
                                  // );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => lockscreenNew()),
                                  );
                                },
                                child: Container(
                                  // padding: EdgeInsets.all(8),

                                  /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                      Image.asset("assets/images/icons8-play-100.png",
                                          height: imageSize, width: imageSize),
                                      Text('Lock'.tr,
                                          style: TextStyle(fontSize: 12, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => vehicle_info()),
                                    //builder: (context) => vehicle_dasboard()),
                                  );

                                  //_onMapTypeButtonPressed();
                                },
                                child: Container(
                                  //   padding: EdgeInsets.all(8),

                                  /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/images/icons8-info-popup-100.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('VehicleInfo'.tr,
                                          style: TextStyle(fontSize: 12, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            tripinfoselectionscreen()),
                                    //   builder: (context) => tasks()),
                                  );
                                },
                                child: Container(
                                  //  padding: EdgeInsets.all(8),

                                  /*   decoration: new BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius:BorderRadius.all(Radius.circular(15)),
                                  // borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 1.0,
                                      //offset: const Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),*/
                                  // color: Colors.white,
                                  //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/images/icons8-bar-chart-100.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('Trips'.tr,
                                          style: TextStyle(fontSize: 12, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: Column(
                        //     children: <Widget>[
                        //       GestureDetector(
                        //         onTap: () {
                        //           _poidialogPopup(context);
                        //           final url =
                        //               'https://maps.google.com/maps?q=atm&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                        //           // Navigator.push(
                        //           //     context,
                        //           //     MaterialPageRoute(
                        //           //         builder: (context) => Browser(
                        //           //           dashboardName: "NearBy Location",
                        //           //           dashboardURL: url,
                        //           //         )));
                        //           //  MapUtils.openMap(url);
                        //         },
                        //         child: Container(
                        //           //padding: EdgeInsets.all(8),
                        //
                        //           /*   decoration: new BoxDecoration(
                        //           color: Colors.white,
                        //           shape: BoxShape.rectangle,
                        //           borderRadius:BorderRadius.all(Radius.circular(15)),
                        //           // borderRadius: BorderRadius.circular(8),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black26,
                        //               blurRadius: 1.0,
                        //               //offset: const Offset(0.0, 10.0),
                        //             ),
                        //           ],
                        //         ),*/
                        //           // color: Colors.white,
                        //           //color: Color(0x99FFFFFF),
                        //             child: Column(children: <Widget>[
                        //               Image.asset("assets/nepalicon/nearby.png",
                        //                   height: imageSize, width: imageSize),
                        //               Text('NearBy'.tr,
                        //                   style: TextStyle(fontSize: 12, height: 2.0))
                        //             ])),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Container(
                  //  // margin: EdgeInsets.only(top: 12),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //
                  //       Expanded(
                  //         child: Column(
                  //           children: <Widget>[
                  //             GestureDetector(
                  //               onTap: () {
                  //
                  //                 Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                   //    builder: (context) => tripinfoselectionscreen()),
                  //                     builder: (context) => tasks()),
                  //                 );
                  //               },
                  //               child: Container(
                  //                   padding: EdgeInsets.all(8),
                  //
                  //                /*   decoration: new BoxDecoration(
                  //                     color: Colors.white,
                  //                     shape: BoxShape.rectangle,
                  //                     borderRadius:BorderRadius.all(Radius.circular(15)),
                  //                     // borderRadius: BorderRadius.circular(8),
                  //                     boxShadow: [
                  //                       BoxShadow(
                  //                         color: Colors.black26,
                  //                         blurRadius: 1.0,
                  //                         //offset: const Offset(0.0, 10.0),
                  //                       ),
                  //                     ],
                  //                   ),*/
                  //                   // color: Colors.white,
                  //                   //color: Color(0x99FFFFFF),
                  //                   child:   Column(
                  //                       children: <Widget>[
                  //                         Image.asset("assets/images/icons8-bar-chart-100.png", height: imageSize,width: imageSize),
                  //                         Text('Trips'.tr,  style: TextStyle(
                  //                             fontSize: 12,height: 2.0))
                  //                       ]
                  //                   )
                  //               ),
                  //             ),
                  //           ],
                  //
                  //         ),
                  //       ),
                  //
                  //     ],
                  //   ),
                  // )
                ],
              ));
        });
  }

  // add marker
  Set<Marker> getmarkers(double lat, double lng, double course, String imei) {
    // void _addMarker(double lat, double lng,int index) {
    LatLng position = LatLng(lat, lng);

    // set initial marker
    markers.add(Marker(
      markerId: MarkerId(imei),
      anchor: Offset(0.5, 0.5),
      position: position,
      rotation: course,
      /*  infoWindow: InfoWindow(title: 'This is marker 1'),
      onTap: () {
        Fluttertoast.showToast(msg: 'Click marker', toastLength: Toast.LENGTH_SHORT);
      },*/
      icon: _markerDirection,
    ));

    if (_controller != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    }

    return markers;
  }
  /*void _recenterall(){
    CameraUpdate u2=CameraUpdate.newLatLngBounds(LatLngBounds([]), 50);
    this._controller!.moveCamera(u2).then((void v){
      _check(u2,this._controller!);
    });
  }*/

  /* start additional function for camera update
  - we get this function from the internet
  - if we don't use this function, the camera will not work properly (Zoom to marker sometimes not work)
  */
  void _check(CameraUpdate u, GoogleMapController c) async {
    c.moveCamera(u);
    _controller!.moveCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      _check(u, c);
  }

  // when the Google Maps Camera is change, get the current position
  void _onGeoChanged(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  // build google maps to used inside widget
  Widget _buildGoogleMap(double lat, double lng, double course, String imei) {
    return Container(
        height: 200,
        child: GoogleMap(
          mapType: MapType.normal,
          trafficEnabled: false,
          //compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          mapToolbarEnabled: true,
          markers: getmarkers(lat, lng, course, imei),
          //markers: Set.of((_marker != null) ? [_marker!] : []),
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: _currentZoom,
          ),
          // onCameraMove: _onGeoChanged,
          onCameraMove: (cameraPosition) {
            lat = cameraPosition.target.longitude; //gets the center longitude
            lng = cameraPosition.target.latitude; //gets the center lattitude
          },
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            //_timerDummy = Timer(Duration(milliseconds: 300), () {
            setState(() {
              _mapLoading = true;

              _controller!.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
              Fluttertoast.showToast(
                  msg:
                  '_controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));',
                  toastLength: Toast.LENGTH_SHORT);
              /* Future.delayed(Duration(seconds: 1), () async {
              GoogleMapController controller = await _mapController.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 17.0,
                  ),
                ),
              );
            });*/
              /*_controller?.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(target:LatLng(lat, lng), zoom: 17)
                  //17 is new zoom level
                )
            );*/

              /*CameraUpdate u2 = CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 15));

            this._controller.moveCamera(u2).then((void v) {
              _check(u2, this._controller);
            });*/
              //getmarkers(lat, lng,index);
              //_addMarker(lat, lng,index);
            });
            //  });
          },
          onTap: (pos) {
            print('currentZoom : ' + _currentZoom.toString());
          },
        ));
  }

  //
  // Widget _buildGoogleMap() {
  //   return
  //     Container(
  //       height: 80,
  //       child:GoogleMap(
  //         mapType: MapType.normal,
  //         trafficEnabled: false,
  //         compassEnabled: false,
  //         rotateGesturesEnabled: true,
  //         scrollGesturesEnabled: true,
  //         tiltGesturesEnabled: true,
  //         zoomControlsEnabled: false,
  //         zoomGesturesEnabled: true,
  //         myLocationButtonEnabled: false,
  //         myLocationEnabled: true,
  //         mapToolbarEnabled: false,
  //         markers: Set<Marker>.of(_allMarker.values),
  //         initialCameraPosition: CameraPosition(
  //           target: _initialPosition,
  //           zoom: _currentZoom,
  //         ),
  //         onCameraMove: _onGeoChanged,
  //         onCameraIdle: (){
  //           if(_isBound==false && _doneListing==true) {
  //             _isBound = true;
  //             CameraUpdate u2=CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 50);
  //             this._controller.moveCamera(u2).then((void v){
  //               _check(u2,this._controller);
  //             });
  //           }
  //         },
  //         onMapCreated: (GoogleMapController controller) {
  //           _controller = controller;
  //
  //           // we use timer for this demo
  //           // in the real application, get all marker from database
  //           // Get the marker from API and add the marker here
  //           _timerDummy = Timer(Duration(seconds: 0), () {
  //
  //             setState(() {
  //               _mapLoading = false;
  //
  //               // add all marker here
  //               /*   for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
  //
  //               if(StaticVarMethod.devicelist[i].lat != 0) {
  //
  //                   var color;
  //                   if(StaticVarMethod.devicelist[i].online!.contains('online')){
  //                     color=Colors.green;
  //                   }else if(productData.speed! > 0){
  //                     color=Colors.green;
  //                   }else{
  //                     color=Colors.red;
  //                   }
  //                   double lat = StaticVarMethod.devicelist[i].lat as double;
  //                   double lng = StaticVarMethod.devicelist[i].lng as double;
  //                   //double angle =  StaticVarMethod.devicelist[i].course as double;
  //                   LatLng position = LatLng(lat, lng);
  //                   _latlng.add(position);
  //                   _createImageLabel(label: StaticVarMethod.devicelist[i].name.toString(), imageIcon: _iconFacebook,course :StaticVarMethod.devicelist[i].course.toDouble(),color: color).then((BitmapDescriptor customIcon) {
  //                       setState(() {
  //                       _mapLoading = false;
  //                     _allMarker[MarkerId(i.toString())] = Marker(
  //                     markerId: MarkerId(i.toString()),
  //                     position: position,
  //                     //rotation: 0.0,
  //                     infoWindow: InfoWindow(
  //                         title: 'This is marker ' + (i + 1).toString()),
  //                     onTap: () {
  //                       Fluttertoast.showToast(
  //                           msg: 'Click marker ' + (i + 1).toString(),
  //                           toastLength: Toast.LENGTH_SHORT);
  //                     },
  //                     icon:  customIcon
  //                   );
  //                   });
  //                   });
  //                   if (i == StaticVarMethod.devicelist.length - 1) {
  //                     _doneListing = true;
  //                   }
  //
  //               }
  //
  //
  //           }*/
  //               updateMarker();
  //               // zoom to all marker
  //               if(_isBound==false && _doneListing==true) {
  //                 _isBound = true;
  //                 CameraUpdate u2=CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 100);
  //                 this._controller.moveCamera(u2).then((void v){
  //                   _check(u2,this._controller);
  //                 });
  //               }
  //               _mapLoading = false;
  //             });
  //
  //           });
  //         },
  //         onTap: (pos){
  //           print('currentZoom : '+_currentZoom.toString());
  //         },
  //       ),
  //     );
  // }
  //
  // updateMarker(){
  //
  //   Fluttertoast.showToast(
  //       msg: 'Click marker ' + ( 1).toString(),
  //       toastLength: Toast.LENGTH_SHORT);
  //   //_allMarker.clear();
  //   for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
  //
  //     if(StaticVarMethod.devicelist[i].lat != 0) {
  //
  //       var color;
  //       var label;
  //
  //       if(productData.speed!.toInt() > 0){
  //         color=Colors.green;
  //         label= StaticVarMethod.devicelist[i].name.toString() + '('+productData.speed!.toString()+' km)';
  //       }
  //       else  if(StaticVarMethod.devicelist[i].online!.contains('online')){
  //         color=Colors.green;
  //         label= StaticVarMethod.devicelist[i].name.toString();
  //
  //       }else{
  //         color=Colors.red;
  //         label= StaticVarMethod.devicelist[i].name.toString();
  //       }
  //       double lat = StaticVarMethod.devicelist[i].lat as double;
  //       double lng = StaticVarMethod.devicelist[i].lng as double;
  //       //double angle =  StaticVarMethod.devicelist[i].course as double;
  //       LatLng position = LatLng(lat, lng);
  //       _latlng.add(position);
  //       _createImageLabel(label: label,course :StaticVarMethod.devicelist[i].course.toDouble(),color: color).then((BitmapDescriptor customIcon) {
  //         if (mounted) {
  //           setState(() {
  //             _mapLoading = false;
  //             _allMarker[MarkerId(i.toString())] = Marker(
  //                 markerId: MarkerId(i.toString()),
  //                 position: position,
  //                 //rotation: 0.0,
  //                 infoWindow: InfoWindow(
  //                     title: 'This is marker ' + (i + 1).toString()),
  //                 onTap: () {
  //                   Fluttertoast.showToast(
  //                       msg: 'Click marker ' + (i + 1).toString(),
  //                       toastLength: Toast.LENGTH_SHORT);
  //                 },
  //                 anchor: Offset(0.5, 0.5),
  //                 icon:  customIcon
  //             );
  //           });
  //         }
  //
  //       });
  //       if (i == StaticVarMethod.devicelist.length - 1) {
  //         _doneListing = true;
  //       }
  //
  //     }
  //
  //
  //   }
  // }
  //
  // Set<Marker> getmarkers()  {
  //
  //
  // /*  return await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //       "assets/icons/igniton.png"
  //   );*/
  // /*  for(int mrk = 0; mrk < vehicleList.length; mrk++){
  //     _setMarkerIcon() async {
  //       if(vehicleList[mrk].ignition == true){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/igniton.png"
  //         );
  //       } else if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == false){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/ignitidle.png"
  //         );
  //       } else if(vehicleList[mrk].ignition != true){
  //         _markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: .5),
  //             "assets/icons/ignitoff.png"
  //         );
  //
  //       }
  //
  //
  //       return _markerIcon;
  //     }
  //     if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == false){
  //       markers.add(
  //           Marker(
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _idlemarkerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //     else if(vehicleList[mrk].ignition == true && vehicleList[mrk].motion == true){
  //       markers.add(
  //           Marker(
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _markerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //     else if(vehicleList[mrk].ignition != true) {
  //       markers.add(
  //           Marker(
  //
  //             markerId: MarkerId(vehicleList[mrk].location.toString()),
  //             position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //             icon:  _offmarkerIcon,
  //             rotation: vehicleList[mrk].heading!.toDouble(),
  //             infoWindow: InfoWindow(
  //               title: vehicleList[mrk].location,
  //             ),
  //           )
  //       );
  //     }
  //
  //
  //   }*/
  //
  //  /* markers.add(
  //       Marker(
  //         markerId: MarkerId(vehicleList[mrk].location.toString()),
  //         position: LatLng(vehicleList[mrk].latitude!.toDouble(), vehicleList[mrk].longitude!.toDouble()),
  //         icon:  _idlemarkerIcon,
  //         rotation: vehicleList[mrk].heading!.toDouble(),
  //         infoWindow: InfoWindow(
  //           title: vehicleList[mrk].location,
  //         ),
  //       )
  //   );*/
  //   return markers;
  // }
  void showPopupDeleteFavorite(index, boxImageSize) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('No', style: TextStyle(color: SOFT_BLUE)));
    Widget continueButton = TextButton(
        onPressed: () {
          int removeIndex = index;
          var removedItem = _vehiclesData.removeAt(removeIndex);
          // This builder is just so that the animation has something
          // to work with before it disappears from view since the original
          // has already been deleted.
          AnimatedRemovedItemBuilder builder = (context, animation) {
            // A method to build the Card widget.
            return _buildItem(removedItem, boxImageSize, removeIndex);
          };
          _listKey.currentState!.removeItem(removeIndex, builder);

          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: 'Item has been deleted from your favorite',
              toastLength: Toast.LENGTH_SHORT);
        },
        child: Text('Yes', style: TextStyle(color: SOFT_BLUE)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        'Delete Favorite',
        style: TextStyle(fontSize: 18),
      ),
      content: Text('Are you sure to delete this item from your Favorite ?',
          style: TextStyle(fontSize: 13, color: _color1)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future refreshData() async {
    // setState(() {
    //   _vehiclesData.clear();
    //   _loading = true;
    //   //_getData();
    // });
  }

  Widget kmandfueldetail(int deviceId) {
    var dev = deviceId;
    return FutureBuilder<History>(
        future: gpsapis.getHistory(deviceId),
        builder: (context, AsyncSnapshot<History> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    snapshot.data!.distanceSum.toString() + ' km',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0.00',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0 km',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 0),
                  child: Text(
                    '0.00',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget addressLoad(String lat, String lng) {
    return FutureBuilder<String>(
        future: gpsapis.geocode(lat, lng),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Container(
              //color: Colors.red,
              height: 35,
              width: 305,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Text(
                (snapshot.data!.replaceAll('"', '')),
                style: TextStyle(
                    color: Colors.black, fontFamily: "Popins", fontSize: 9),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            );
            // return Text(snapshot.data!.replaceAll('"', ''),
            //   style: TextStyle(
            //       color: Colors.black,
            //       fontFamily: "Popins",
            //       fontSize: 9),);
          } else {
            return Text("loading...");
          }
        });
  }

  launchWhatsApp(num, text) async {
    final link = WhatsAppUnilink(
      //  phoneNumber: num,
      text: text,
    );
    await launch('$link');
  }

  void _poidialogPopup(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width / 15;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(
                child: Text('NearBy POI', style: TextStyle(fontSize: 12))),
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    margin: EdgeInsets.only(top: 1, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=atm&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/nepalicon/atm_machine.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('ATM',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Petrol Pump&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(

                                  //color: Color(0x99FFFFFF),
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/nepalicon/petrol_pump.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('Petrol Pump',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Gas Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset("assets/nepalicon/gas_pump.png",
                                          height: imageSize, width: imageSize),
                                      Text('Gas Station',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Charge Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/nepalicon/battery_volt.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('Charge Station',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.only(/*top: 12,*/ bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Police Station&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset(
                                          "assets/nepalicon/police_station.png",
                                          height: imageSize,
                                          width: imageSize),
                                      Text('Police Station',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restaurant&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset("assets/nepalicon/restaurant.png",
                                          height: imageSize, width: imageSize),
                                      Text('Restaurant',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=hospital&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset("assets/nepalicon/hospital.png",
                                          height: imageSize, width: imageSize),
                                      Text('Medical',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  final url =
                                      'https://maps.google.com/maps?q=Restroom&cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                                  MapUtils.openMap(url);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    child: Column(children: <Widget>[
                                      Image.asset("assets/nepalicon/hotel.png",
                                          height: imageSize, width: imageSize),
                                      Text('Restroom',
                                          style:
                                          TextStyle(fontSize: 10, height: 2.0))
                                    ])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ]),
              /* SimpleDialogOption(
                onPressed: (){
                  Navigator.pop(context, 'user01@gmail.com');
                  Fluttertoast.showToast(msg: 'user01@gmail.com', toastLength: Toast.LENGTH_SHORT);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 36.0, color: Colors.orange),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16.0),
                      child: Text('user01@gmail.com'),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: (){
                  Navigator.pop(context, 'user02@gmail.com');
                  Fluttertoast.showToast(msg: 'user02@gmail.com', toastLength: Toast.LENGTH_SHORT);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 36.0, color: Colors.green),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16.0),
                      child: Text('user02@gmail.com'),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: (){
                  Navigator.pop(context, 'Add account');
                  Fluttertoast.showToast(msg: 'Add account', toastLength: Toast.LENGTH_SHORT);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 36.0, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16.0),
                      child: Text('Add account'),
                    ),
                  ],
                ),
              )*/
            ],
          );
        });
  }
}
