import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';



import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maktrogps/config/custom_marker.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/mvvm/view_model/objects.dart';
import 'package:provider/provider.dart';



class MapRoutePage extends StatefulWidget {
  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> with AutomaticKeepAliveClientMixin<MapRoutePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.indigo,
            fontFamily: 'Poppins',
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
            )),
        initialRoute: MapPage.screen,
        routes: {
          MapPage.screen: (context) => MapPage(),
        },
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  static const String screen = "map_page";

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  GoogleMapController? _controller;

  bool isTrafficEnabled = false;
  bool showAllVehicles = true;

  //initial LatLong(Mirpur Lat: 23.807140, Lng: 90.368709
  LatLng _center = const LatLng(42.7339, 25.4858);
  bool isMoreClicked = false;
  String tappedMarkerImei = "";
  bool isRefreshing = false;

  AnimationController? moreButtonAnimationController;
  AnimationController? currentButtonAnimationController;
  AnimationController? vehicleButtonAnimationController;

  Set<Marker> _markers = Set<Marker>();
  MapType _mapType = MapType.normal;
  CameraUpdate? _cameraUpdate;
  LatLng _initialPosition = LatLng(35.168033, 74.900467);

  Future<void> _setMarkers(List<deviceItems> itemList) async {
    _markers.clear();

    try {
      _initialPosition = LatLng(itemList[0].lat!.toDouble(),
          itemList[0].lng!.toDouble());
    } catch (Ex) {
      print(Ex);
      print(" _initialPosition Error occurred");
      //History model = new  History();
      // return model;
    }
    double? x0, x1, y0, y1;

    for (int i = 0; i < itemList.length; i++) {


      String other =itemList[i].deviceData!.traccar!.other.toString();
      String ignition="false";

      if(other.contains("<ignition>")){
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        ignition = other.substring(startIndex + start.length, endIndex);
      }
      if (itemList[i].lat != 0) {
        var color;
        var label;

        // String iconpath = 'assets/tbtrack/truck_toprunning.png';
        String iconpath = 'assets/tbtrack/car_toprunning.png';
        if (itemList[i].speed!.toInt() > 0) {
          // iconpath = 'assets/tbtrack/truck_toprunning.png';
          iconpath = 'assets/tbtrack/car_toprunning.png';
          color = Colors.green;
          label = itemList[i].name.toString() +
              '(' +
              itemList[i].speed!.toString() +
              ' km/h)'/*' mi)'*/;
          if(StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString())!=null)
            iconpath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString()).toString()+"toprunning.png";

        }
        else if (ignition.contains("true") &&
            double.parse(itemList[i].speed.toString()) < 1.0) {
          //iconpath = 'assets/tbtrack/truck_topidle.png';
          iconpath = 'assets/tbtrack/car_topidle.png';
          color = Colors.yellow;
          label = itemList[i].name.toString();
          if(StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString())!=null)
            iconpath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString()).toString()+"topidle.png";

        }
        else if (itemList[i].online!.contains('online')) {
          //iconpath = 'assets/tbtrack/truck_toprunning.png';
          iconpath = 'assets/tbtrack/car_toprunning.png';
          color = Colors.green;
          label = itemList[i].name.toString();
          if(StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString())!=null)
            iconpath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString()).toString()+"toprunning.png";

        }
        else {
          // iconpath = 'assets/tbtrack/truck_topstop.png';
          iconpath = 'assets/tbtrack/car_topstop.png';

          color = Colors.red;
          label = itemList[i].name.toString();

          if(StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString())!=null)
            iconpath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(itemList[i].deviceData!.imei.toString()).toString()+"topstop.png";

        }
        double lat = itemList[i].lat as double;
        double lng = itemList[i].lng as double;
        // String iconpath = devicesList[i].icon!.path.toString();
        //double angle =  devicesList[i].course as double;
        LatLng position = LatLng(lat, lng);



        if (lat == null || lat == 0.0) {
          continue;
        }
        var marker;

        //List markerDataList = await getVehicleMarkerData(devicesList[i].deviceData!.imei.toString(), fnObjectItem.st, fnSettingItem.icon);
        marker = await getCustomMarker(
            iconpath, label, double.parse(itemList[i].speed.toString()) > 1.0 ? itemList[i].speed.toString() + " km/h" : itemList[i].speed.toString(), color, devicesList[i].course.toDouble());

        LatLng latLng = LatLng(lat, lng);

        if (x0 == null) {
          x0 = x1 = latLng.latitude;
          y0 = y1 = latLng.longitude;
        } else {
          if (latLng.latitude > x1!) x1 = latLng.latitude;
          if (latLng.latitude < x0!) x0 = latLng.latitude;
          if (latLng.longitude > y1!) y1 = latLng.longitude;
          if (latLng.longitude < y0!) y0 = latLng.longitude;
        }
        _markers.add(Marker(
          onTap: () {
            if (tappedMarkerImei == devicesList[i].deviceData!.imei.toString()) {
              //  Navigator.push(context, MaterialPageRoute(builder: (context) => ListItemPage(imei, fnObjectItem, fnSettingItem)));
            } else {
              _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)));
              tappedMarkerImei = devicesList[i].deviceData!.imei.toString();
            }
          },
          markerId: MarkerId(devicesList[i].deviceData!.imei.toString()),
          position: latLng,
          icon: marker == null ? BitmapDescriptor.defaultMarker : marker /*BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)*/,
        ));
      }

      if (showAllVehicles && mounted && x1 != null && x0 != null && y1 != null && y0 != null && _controller != null) {
        showAllVehicles = false;

        _cameraUpdate = CameraUpdate.newLatLngBounds(LatLngBounds(northeast: LatLng(x1 == null ? 0 : x1, y1 == null ? 0 : y1), southwest: LatLng(x0 == null ? 0 : x0, y0 == null ? 0 : y0)), 100);

        _controller!.animateCamera(_cameraUpdate!);
      }
      if (mounted) {
        setState(() {});
      }
      }


  }

  Timer? _timer;

  Future<BitmapDescriptor> getCustomMarker(String img, String name, String speed, Color color, double angle) async {
    return await getMarkerIconWithInfo(
        img,
        name + " (" + speed + ")",

          TextSpan(
              //if need to pass different font text then use nested TextSpan like bellow or you can pass just TestSpan with String and Style
              children: [
                TextSpan(
                  text: speed,
                  style: TextStyle(
                    fontSize: (speed == "P" || speed == "I" || speed == "O") ? 45.0 : 20.0,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ]),

        color,
        angle);
  }

  List<deviceItems> _inactiveVehicles = [];
  List<deviceItems> _runningVehicles = [];
  List<deviceItems> _idleVehicles = [];
  List<deviceItems> _stoppedVehicles = [];

  List<deviceItems> devicesList = [];
  late ObjectStore objectStore;

  @override
  void initState() {
    super.initState();
    moreButtonAnimationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    currentButtonAnimationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    vehicleButtonAnimationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
   // fetchOfflineData();
    //fetchOnlineData();
    // internetConnectionCheck();
  }

  // fetchOnlineData() {
  //   if (settingItemList.length == 0) {
  //     fetchFnSettings().then((isFnSettingFetched) {
  //       if (isFnSettingFetched) {
  //         parseFnSettings();
  //         startTimer();
  //       }
  //     });
  //   } else {
  //     startTimer();
  //   }
  // }
  //
  // startTimer() {
  //   if (_timer == null) {
  //     _timer = Timer.periodic(Duration(seconds: 10), (timer) {
  //       loadFnObjects();
  //     });
  //   }
  // }
  //
  // loadFnObjects() {
  //   fetchFnObjects().then((success) {
  //     if (success) {
  //       var value = getAllFnObjects();
  //       if (isRefreshing) {
  //         isRefreshing = false;
  //         Navigator.pop(context);
  //       }
  //       fnObjects = value;
  //       _setMarkers(fnObjects);
  //     }
  //   });
  // }
  //
  // void fetchOfflineData() {
  //   Map<String, FnSettingItem> pFnSettings = parseFnSettings();
  //   if (pFnSettings.length > 0) {
  //     Map<String, FnObjectItem> pFnObjects = getAllFnObjects();
  //     settingItemList = pFnSettings;
  //     fnObjects = pFnObjects;
  //     _setMarkers(fnObjects);
  //   }
  // }

  void _currentLocation(bool animateLocation) async {
    var location = new Location();
    location.getLocation().then((currentLocation) {
      LatLng latLng = LatLng(currentLocation.latitude as double, currentLocation!.longitude  as double);
      _controller!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: latLng,
          zoom: 17.0,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    StaticVarMethod.devicelist=[];
    objectStore = Provider.of<ObjectStore>(context);
    devicesList = objectStore.objects;

    StaticVarMethod.devicelist=devicesList;
    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      deviceItems model = StaticVarMethod.devicelist.elementAt(i);

      String other =model.deviceData!.traccar!.other.toString();
      String ignition="false";
      if(other.contains("<ignition>")){
        const start = "<ignition>";
        const end = "</ignition>";
        final startIndex = other.indexOf(start);
        final endIndex = other.indexOf(end, startIndex + start.length);
        ignition = other.substring(startIndex + start.length, endIndex);
      }
      if (ignition.contains("true") &&
          double.parse(model.speed.toString()) < 1.0) {
        _idleVehicles.add(StaticVarMethod.devicelist.elementAt(i));
      }
      else if (model.online.toString().toLowerCase().contains("offline") &&
          model.time.toString().toLowerCase().contains("not connected")) {
        _inactiveVehicles.add(StaticVarMethod.devicelist.elementAt(i));
      } else if (model.online.toString().toLowerCase().contains("online")) {
        _runningVehicles.add(StaticVarMethod.devicelist.elementAt(i));
      }  else if (ignition.contains("false")  &&
          model.time.toString().toLowerCase() != "not connected") {
        _stoppedVehicles.add(StaticVarMethod.devicelist.elementAt(i));
      }
    }
    _setMarkers(devicesList);
    print("Map Builder");

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                gestureRecognizers: Set()
                  ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                  ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                  ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                  ..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()))
                  ..add(Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer())),
                myLocationButtonEnabled: false,
                mapType: _mapType,
                myLocationEnabled: true,
                trafficEnabled: isTrafficEnabled,
                zoomControlsEnabled: false,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 4.0,
                ),
              ),

              //refresh
              Positioned(
                left: 22.0,
                bottom: 153.0,
                child: InkWell(
                  onTap: () {
                    // isRefreshing = true;
                    // showDialog(
                    //   barrierColor: Colors.white.withOpacity(0),
                    //   context: context,
                    //   useRootNavigator: false,
                    //   builder: (context) => LoadingDialog(),
                    // );
                    // showAllVehicles = true;
                    // loadFnObjects();
                  },
                  child: CircleAvatar(
                    /// Modify => radiuus
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage(
                      'images/refresh.png',
                    ),
                  ),
                ),
              ),

              // more
              Positioned(
                left: 14.0,
                bottom: 85.0,
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          moreButtonAnimationController!.forward();
                          isMoreClicked = !isMoreClicked;
                        });
                      },
                      child: ScaleTransition(
                        scale: Tween(begin: 1.0, end: .8).animate(CurvedAnimation(parent: moreButtonAnimationController!, curve: Curves.bounceIn))
                          ..addStatusListener((status) {
                            if (status == AnimationStatus.completed) {
                              moreButtonAnimationController!.reverse();
                            }
                          }),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(
                            'images/threedotfil.png',
                          ),
                        ),
                      ),
                    ),
                    isMoreClicked
                        ? Container(
                            padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                            margin: EdgeInsets.only(bottom: 7.0),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(30.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 3.0, offset: Offset(0, 3))]),
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                    child: Image.asset(
                                      'images/lefttrafic.png',
                                      height: 23,
                                      width: 23,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (_mapType == MapType.normal)
                                          _mapType = MapType.terrain;
                                        else if (_mapType == MapType.terrain)
                                          _mapType = MapType.satellite;
                                        else if (_mapType == MapType.satellite)
                                          _mapType = MapType.hybrid;
                                        else if (_mapType == MapType.hybrid) _mapType = MapType.normal;
                                      });
                                    }),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isTrafficEnabled = !isTrafficEnabled;
                                    });
                                  },
                                  child: Image.asset(
                                    isTrafficEnabled ? 'images/traffic-lights-active.png' : 'images/traffic-lights.png',
                                    height: 23,
                                    width: 23,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),

              //current location
              /// Modify => Next Positioned Widget
              Positioned(
                right: 14.0,
                bottom: 87.0,
                child: InkWell(
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: .8).animate(CurvedAnimation(parent: currentButtonAnimationController!, curve: Curves.bounceIn))
                      ..addStatusListener((status) {
                        if (status == AnimationStatus.completed) {
                          currentButtonAnimationController!.reverse();
                        }
                      }),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('images/current_location.png'),
                    ),
                  ),
                  onTap: () {
                    currentButtonAnimationController!.forward();
                    // getLocationPermission().then((isLocationPermissionGranted) {
                    //   if (isLocationPermissionGranted) {
                    //     _currentLocation(true);
                    //   }
                    // }
                   // );
                  },
                ),
              ),

              /// Modify => Next Positioned Widget
              Positioned(
                right: 14.0,
                bottom: 145.0,
                child: InkWell(
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: .8).animate(CurvedAnimation(parent: vehicleButtonAnimationController!, curve: Curves.bounceIn))
                      ..addStatusListener((status) {
                        if (status == AnimationStatus.completed) {
                          vehicleButtonAnimationController!.reverse();
                        }
                      }),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('images/vehicle.png'),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    vehicleButtonAnimationController!.forward();
                    showAllVehicles = true;
                    //_setMarkers(fnObjects);
                  },
                ),
              ),
            ],
          ),
        ));



  }


  @override
  dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }
}
