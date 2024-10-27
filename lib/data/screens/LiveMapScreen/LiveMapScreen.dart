import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:math' as m;
import 'dart:ui' as ui;
import 'package:alxgration_speedometer/speedometer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart' as streeview;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maktrogps/data/model/GeofenceModel.dart';
import 'package:maktrogps/data/model/gefanceparkmodel.dart';
import 'package:maktrogps/data/screens/LiveMapScreen/streetview.dart';
import 'package:maktrogps/data/screens/browser_module_old/browser.dart';
import 'package:maktrogps/data/screens/lockscreenNew.dart';
import 'package:maktrogps/data/screens/parkingAlertpage.dart';
import 'package:maktrogps/data/screens/playbackselection.dart';
import 'package:maktrogps/data/screens/reports/kmdetail.dart';
import 'package:maktrogps/data/screens/reports/vehicle_info.dart';
import 'package:maktrogps/utils/MapUtils.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart' as l;
import 'package:odometer/odometer.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:vector_math/vector_math.dart' as v;
import 'package:flutter/material.dart' as m;
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/constant.dart';
import '../../../config/static.dart';
import '../../../mapconfig/CustomColor.dart';
import '../../../mvvm/view_model/objects.dart';
import '../../../ui/reusable/Mycolor/MyColor.dart';
import '../../model/devices.dart';
import '../trip/tripinfoselectionscreen.dart';


class LiveMapScreen extends StatefulWidget {
  LiveMapScreen({Key? key}) : super(key: key);

  @override
  _LiveMapScreenState createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();

  MapType _currentMapType = MapType.normal;
  Color _mapTypeBackgroundColor = MyColor.primaryColor;
  Color _mapTypeForegroundColor = MyColor.whiteColor;
  Color _mainColor = Color(0xff2e414b);
  double currentZoom = 17.0;
  bool _trafficEnabled = false;
  List<Marker> _markers = <Marker>[];

  DriverData? driverData;
  bool pageDestoryed = false;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  final Set<Polyline> _distancePolyLine = {};

  int distance = 0;

  double todayDistance = 0;
  double averageSpeed = 0;
  double maxSpeed = 0;
  double spentFuel = 0;
  double startOdometer = 0;
  double endOdometer = 0;
  int engineHours = 0;
  bool isLoading = true;
  bool noData = false;
  List<LatLng> newPolylinesData = [];
  List<LatLng> parkPolylinesData = [];
  bool ruler = false;

  Color _trafficBackgroundButtonColor = CustomColor.primaryColor;
  Color _trafficForegroundButtonColor = Colors.white;
  late GoogleMapController mapController;

  bool isFirst = true;
  bool first= true;

  double _dialogHeight = 320.0;
  int _selectedPeriod = 0;
  late GoogleMapController _mapController;
  LatLng? oldPin;

  double _dialogHeightShare = 330.0;
  int _selectedPeriodShare = 0;

  DateTime _selectedToShareDate = DateTime.now();
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  TimeOfDay _selectedFromTime = TimeOfDay.now();
  TimeOfDay _selectedToTime = TimeOfDay.now();



  Animation<double>? _animation;
  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  AnimationController? animationController;
  Set<Circle> _circles = Set<Circle>();
  bool isParked = false;
  String? markerId;
  bool parkingEvent = false;
  bool eventUpdated = false;
  String? eventId;
  String stopTime = "0 s";
  String runTime = "0 s";
  String idleTime = "0 s";
  String inactiveTime = "0 s";
  bool lockStatus = false;
  bool myLocation = false;
  bool isstreetview = false;
  static final CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  Location currentLocation = Location();
  bool _statusbarLoading = true;
  List<deviceItems> devicesList = [];
  late ObjectStore objectStore;
  @override
  void initState() {

    super.initState();
     drawPolyline();
     //drawPolyline2();

  }




  void drawPolyline() async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.blueAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }
  //
  // void drawPolyline2() async {
  //   PolylineId id = PolylineId("polyAnim");
  //   Polyline polyline = Polyline(
  //       width: 3,
  //       polylineId: id,
  //       color: Colors.blueAccent,
  //       points: newPolylinesData);
  //   polylines[id] = polyline;
  //   setState(() {});
  // }

  // void drawPolyline3() async {
  //   PolylineId id = PolylineId("polyPark");
  //   Polyline polyline = Polyline(
  //       width: 3,
  //       polylineId: id,
  //       color: Colors.blueAccent,
  //       points: parkPolylinesData);
  //   polylines[id] = polyline;
  //   setState(() {});
  // }





  String address = "View Address";
  String getAddress(lat, lng) {
    if (lat != null) {
      gpsapis.getGeocoder(lat, lng).then((value) => {
        if (value != null)
          {
            address = value.body,
          //  setState(() {}),
          }
        else
          {address = "Address not found"}
      });
    } else {
      address = "Address not found";
    }
    print(address);
    return address;
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
      _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
      _mapTypeBackgroundColor = _currentMapType == MapType.normal
          ? MyColor.primaryColor
          : MyColor.whiteColor;
      _mapTypeForegroundColor = _currentMapType == MapType.normal
          ? MyColor.whiteColor
          : MyColor.primaryColor;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
      _trafficBackgroundButtonColor = _trafficEnabled == false
          ? MyColor.whiteColor
          : MyColor.primaryColor;

      _trafficForegroundButtonColor = _trafficEnabled == false
          ? MyColor.primaryColor
          : MyColor.whiteColor;
    });
  }

  void reload() async{
     polylines.clear();
     polylineCoordinates.clear();
    // CameraPosition cPosition = CameraPosition(
    //   target: LatLng(double.parse(device.data![0][2].toString()),
    //       double.parse(device.data![0][3].toString())),
    //   zoom: currentZoom,
    // );
    // final GoogleMapController controller = await _controller.future;
    // controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
    //setState(() {});

  }

  @override
  void dispose() {
    pageDestoryed = true;

    if(animationController != null) {
      animationController!.dispose();
    }
    super.dispose();
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  late double lati=23.34334000;
  late double lngi=85.23890000;
  String fUpdateTime = 'Not Found';
  String fspeed ='0';
  int? speedo =0;
  String ftotalDistance ='Not Found';
  String fstopDuration ='Not Found';

  void updateMarker(deviceItems devicelist) async {
    var iconPath;
    var color;
    var label;
    int? speed = int.tryParse(devicelist.speed.toString());
    if(lngi !=devicelist.lat!.toDouble()){
      lati = devicelist.lat!.toDouble();
      lngi = devicelist.lng!.toDouble();
      fUpdateTime=devicelist.time.toString();
      fspeed=devicelist.speed.toString();
      // fspeed= (int.parse(devicelist.speed.toString())/1.6093).toStringAsFixed(0);
      speedo=int.tryParse(devicelist.speed.toString());
      ftotalDistance=devicelist.totalDistance.toString();
      fstopDuration=devicelist.stopDuration.toString();
      // String replacePath = category.replaceAll("img/markers/objects/land-", "");
      // String replacePath2 = replacePath.replaceAll(".svg", "");
      // String finalImg = replacePath2.replaceAll(RegExp('[^A-Za-z]'),'');






      Uint8List markerIcon;
      try {
        if(MediaQuery.of(context).size.aspectRatio > 0.55){
          markerIcon = await getBytesFromAsset(iconPath, 40);
        }else{
          markerIcon = await getBytesFromAsset(iconPath, 60);
        }
      }catch(e){
        String other =devicelist.deviceData!.traccar!.other.toString();
        String ignition="false";
        if(other.contains("<ignition>")){
          const start = "<ignition>";
          const end = "</ignition>";
          final startIndex = other.indexOf(start);
          final endIndex = other.indexOf(end, startIndex + start.length);
          ignition = other.substring(startIndex + start.length, endIndex);
        }
        if(int.tryParse(devicelist.speed.toString())! > 0){

          colormain=Colors.green.withOpacity(0.5);
          iconPath =  "assets/tbtrack/truck_toprunning.png";
         // iconPath =  "assets/tbtrack/car_toprunning.png";
          color=Colors.green;
          label= devicelist.name.toString() + '('+devicelist.speed!.toString()+' km)';
          if(StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString())!=null)
            iconPath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString()).toString()+"toprunning.png";


          if(isParked){

            isParked=false;
            print(isParked);
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     fullscreenDialog: true,
            //     builder: (context) => parkingAlertpage(),
            //   ),
            // );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => parkingAlertpage()),
            // );

            Future.delayed(const Duration(milliseconds: 5000), () {
              setState(() {
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(builder: (context) => parkingAlertpage()),
                //         (route) => false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => parkingAlertpage()),
                );
              });
            });
          }
        }
        else if (ignition.contains("true") &&
            double.parse(devicelist.speed.toString()) < 1.0) {
          colormain=Colors.yellow.withOpacity(0.5);
          //iconPath = 'assets/tbtrack/truck_topidle.png';
          iconPath = 'assets/tbtrack/truck_topidle.png';
          label= devicelist.name.toString();
          if(StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString())!=null)
            iconPath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString()).toString()+"topidle.png";

        }
        else{
          color=Colors.red;
          colormain=Colors.red.withOpacity(0.5);
          //iconPath =  "assets/tbtrack/truck_topstop.png";
          iconPath =  "assets/tbtrack/truck_topstop.png";
          label= devicelist.name.toString();
          if(StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString())!=null)
            iconPath =  "assets/tbtrack/"+StaticVarMethod.pref_static!.get(devicelist.deviceData!.imei.toString()).toString()+"topstop.png";
        }
        if(MediaQuery.of(context).size.aspectRatio > 0.55){
          markerIcon = await getBytesFromAsset(iconPath, 40);
        }else{
          markerIcon = await getBytesFromAsset(iconPath, 60);
        }
      }

      var pinPosition =  LatLng(
          double.parse(devicelist.lat.toString()), double.parse(devicelist.lng.toString()));

      if (first) {
        CameraPosition cPosition = CameraPosition(
          target: LatLng(
              double.parse(devicelist.lat.toString()), double.parse(devicelist.lng.toString())),
          zoom: currentZoom,
        );

        final pickupMarker = Marker(
          markerId: MarkerId(StaticVarMethod.imei.toString()),
          position:pinPosition,
          rotation: double.parse(devicelist.course.toString()),
          icon: BitmapDescriptor.fromBytes(markerIcon),);

        //Adding a delay and then showing the marker on screen
        await Future.delayed(const Duration(milliseconds: 500));

        _markers.add(pickupMarker);
        _mapMarkerSink.add(_markers);

        oldPin = LatLng(double.parse(devicelist.lat.toString()), double.parse(devicelist.lng.toString()));

        final GoogleMapController controller = await _controller.future;
        controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
        first = false;
      }
      // var pinPosition =  LatLng(
      //     double.parse(value.data![0][2]), double.parse(value.data![0][3]));
      // _markers.removeWhere((m) => m.markerId.value == args.imei);

      getAddress(double.parse(devicelist.lat.toString()), double.parse(devicelist.lng.toString()));
      if (!first){
        Future.delayed(const Duration(seconds: 2)).then((value) {
          if(oldPin != pinPosition) {
            animateCar(
                oldPin!.latitude,
                oldPin!.longitude,
                pinPosition.latitude,
                pinPosition.longitude,
                _mapMarkerSink,
                this,
                _mapController,
                markerIcon/*,
              devicelist.course*/
            );
          }
        });
      }

    }

  }




  animateCar(
      double fromLat, //Starting latitude
      double fromLong, //Starting longitude
      double toLat, //Ending latitude
      double toLong, //Ending longitude
      StreamSink<List<Marker>>
      mapMarkerSink, //Stream build of map to update the UI
      TickerProvider
      provider, //Ticker provider of the widget. This is used for animation
      GoogleMapController controller,
      markerIcon//Google map controller of our widget
      ) async {
    final double bearing =
    getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    _markers.clear();

    var carMarker = Marker(
        markerId: const MarkerId("driverMarker"),
        position: LatLng(fromLat, fromLong),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false);

    //Adding initial marker to the start location.
    _markers.add(carMarker);
    mapMarkerSink.add(_markers);
    animationController = AnimationController(
      duration: const Duration(seconds: 10), //Animation duration of marker
      vsync: provider, //From the widget
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController!)
      ..addListener(() async {
        //We are calculating new latitude and logitude for our marker
        final v = _animation!.value;
        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);

        //Removing old marker if present in the marker array
        if (_markers.contains(carMarker)) _markers.remove(carMarker);

        //New marker location
        carMarker = Marker(
            markerId: const MarkerId("driverMarker"),
            position: newPos,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            rotation: bearing,
            draggable: false);

        //Adding new marker to our list and updating the google map UI.
        _markers.add(carMarker);
        mapMarkerSink.add(_markers);
       // newPolylinesData.add(carMarker.position);
        oldPin = newPos;
        //Moving the google camera to the new animated location.
        // controller.animateCamera(CameraUpdate.newCameraPosition(
        //     CameraPosition(target: newPos, zoom: currentZoom)));
      });

    polylineCoordinates.add(oldPin!);
    animationController!.forward();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(toLat, toLong), zoom: currentZoom)));
    //newPolylinesData.clear();
    // if(polylineCoordinates.length > 20){
    //   polylineCoordinates.removeRange(0, 10);
    // }
    // Future.delayed(Duration(seconds: 7)).then((value) => {
    //   controller.animateCamera(CameraUpdate.newCameraPosition(
    //       CameraPosition(target: LatLng(toLat, toLong), zoom: currentZoom)))
    // });

  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();
    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return v.degrees(m.atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - v.degrees(m.atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return v.degrees(m.atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - v.degrees(m.atan(lng / lat))) + 270;
    }
    return -1;
  }


  @override
  Widget build(BuildContext context) {

    objectStore = Provider.of<ObjectStore>(context);
    devicesList = objectStore.objects;


    var devicemodel= devicesList.where((i) => i.deviceData!.imei!.contains(StaticVarMethod.imei)).single;
    if (devicemodel !=null ) {



      // Navigator.of(context).push(PageRouteBuilder(
      //     fullscreenDialog: true,
      //     pageBuilder:
      //    ));
      updateMarker(devicemodel);
      isLoading = false;
      noData = false;
    }else{
      isLoading = false;
      noData = true;
      // setState(() {
      //   isLoading = false;
      //   noData = true;
      // });
    }

    final double boxImageSize = (MediaQuery.of(context).size.width / 12);

    print("build live track");
    return SafeArea(
        child: Scaffold(
          body: !isLoading ? !noData ?  Stack(
              children: <Widget>[
                buildMap(),
                //speedometer(),



                Positioned(
                  bottom:300,
                  left: 16,
                  child: GestureDetector(
                    onTap: () async {},
                    child:
                    Container(
                      padding: EdgeInsets.all(5),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ( Colors.white),
                        border: Border.all(width: 2, color: Color(0xff0B77EC)),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2.0,
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:Column(
                        children: [
                          Text(''+fspeed, style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600,fontSize: 18,
                          )
                          ),
                          SizedBox(height: 0),
                          Text('km/h', style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400,
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
                  ),
                ),

                // Positioned(
                //   top: 50,
                //   left: 16,
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.pop(context);
                //     },
                //     child: Container(
                //       padding: EdgeInsets.all(5),
                //       width: 36,
                //       height: 36,
                //       child:    Container(
                //           padding: EdgeInsets.all(3),
                //           child: Icon(Icons.arrow_back,
                //             color: Color(0xff0D3D65),
                //             size: 25,
                //           )
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  top: 60,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      _onMapTypeButtonPressed();
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:    Container(
                        padding: EdgeInsets.all(3),
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(0)),
                            child: Image.asset("assets/images/layers.png",
                              height: 1,width: 1,
                              color: Color(0xff0D3D65),)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      _trafficEnabledPressed();
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Icon(Icons.traffic_outlined,
                        color: Color(0xff0D3D65),
                        size: 25,
                      ),
                    ),
                  ),
                ),
                Positioned(

                  top: 140,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {

                      // var location = await currentLocation.getLocation();
                      // String url ="https://www.google.com/maps/dir/?api=1&destination="
                      //     + (StaticVarMethod.lat.toString() + ","
                      //         + StaticVarMethod.lng.toString()) + "&travelmode=walking";
                      // String url ="https://www.google.com/maps/dir/?api=1&destination="
                      //     + ("31.5121208" + ","
                      //         + "74.3189183") + "&travelmode=walking";
                      // https://www.google.com/maps/dir/31.5121208,74.3189183/31.5082421,74.315528/@31.5101906,74.3150513,17z/data=!3m1!4b1!4m2!4m1!3e2
                      // final url="https://www.google.com/maps/dir/"+ StaticVarMethod.lat.toString() + ","+ StaticVarMethod.lng.toString() + "/"+location.latitude.toString()+","+location.longitude.toString()+"/@"+location.latitude.toString()+","+location.longitude.toString()+",15z/data=!4m2!4m1!3e0";

                      MapsLauncher.launchCoordinates(
                          lati, lngi, 'Google Map');

                     // MapUtils.openMap(url);

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => Browser(
                      //           dashboardName: "Distance",
                      //           dashboardURL: url,
                      //         )));

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(0)),
                            child: Image.asset("assets/images/arrow.png",
                              height: 1,width: 1,
                              color: Color(0xff0D3D65),)),
                      ),
                    ),
                  ),
                ),


                (ruler)?Positioned(
                    top: 80,
                    left: 0,
                    right:0,
                    child:  Center(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              // blurRadius: 10.0,
                              //offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child:  Text(
                          '$distance km',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4500),
                          ),
                        ),

                      ),
                    )
                ):Container(),

                Positioned(
                  top: 180,
                  right: 16,

                  child: GestureDetector(
                    onTap: () async {


                      setState(() {
                        myLocation = !myLocation;
                        if (!myLocation) {
                          _mapController.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                  zoom: 18,
                                  target: _markers.last.position,
                                 // bearing: double.parse(snapshot.data._angle)
                               )));
                        } else {

                          getToMyLocation();
                        }
                      });

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:   Container(
                        padding: EdgeInsets.all(3),
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(0)),
                            child: Image.asset("assets/images/mylocation1.png",
                              height: 1,width: 1,
                              color: myLocation ?  Color(0xFFF6F6F6) :Color(0xFF0a3d62),)),
                      ),
                    ),
                  ),
                ),
                /*Positioned(
                  top: 300,
                  right: 16,

                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Icon(Icons.refresh,
                        color: Colors.black26,
                        size: 25,
                      ),
                    ),
                  ),
                ),*/
                Positioned(

                  top: 220,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {

                      setState(() {
                        ruler = !ruler;
                      });
                      if (ruler) {
                        LatLng latLngLast = _markers.last.position;
                        List<LatLng> latLngDistance = [];
                        var location = await currentLocation.getLocation();
                        try {

                          latLngDistance.add(
                              LatLng(location.latitude ?? 0.0, location.longitude  ?? 0.0));
                          latLngDistance.add(latLngLast);
                        } on Exception {}
                        List<double> latitude = [];
                        List<double> longitude = [];
                        for (int i = 0; i < latLngDistance.length; i++) {
                          latitude.add(latLngDistance[i].latitude);
                          longitude.add(latLngDistance[i].longitude);
                        }
                        int distanceTemp = calculateDistance(
                            latLngDistance.first.latitude,
                            latLngDistance.first.longitude,
                            latLngDistance.last.latitude,
                            latLngDistance.last.longitude)
                            .toInt();
                        setState(() {
                          _distancePolyLine.clear();
                          _distancePolyLine.add(Polyline(
                            polylineId: PolylineId(latLngDistance.last.toString()),
                            visible: ruler,
                            points: latLngDistance,
                            jointType: JointType.round,
                            endCap: Cap.roundCap,
                            width: 2,
                            startCap: Cap.roundCap,
                            color: Colors.red,
                          ));
                          _mapController.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(target: latLngDistance.last, bearing: 0)));
                          _mapController.animateCamera(CameraUpdate.newLatLngBounds(
                              getBounds(latitude, longitude), 100));
                          distance = distanceTemp;
                        });
                      } else {
                        _mapController
                            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                          zoom: 18,
                          target: _markers.last.position,
                          // bearing: double.parse(snapshot.data._angle),
                        )));
                      }

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(0)),
                            child: Icon(
                              FontAwesomeIcons.ruler,
                              size: 15,
                              color: ruler ? Color(0xFFF6F6F6) : Color(0xFF0a3d62),
                            ),),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 180,
                //   right: 16,
                //
                //   child: GestureDetector(
                //     onTap: () async {
                //       final url ='Street View ,${StaticVarMethod.lat},${StaticVarMethod.lng}';
                //
                //
                //       MapsLauncher.launchQuery(url);
                //       /*      if (await canLaunchUrl(Uri.parse(url))) {
                //   await launchUrl(Uri.parse(url));
                // } else {
                //   throw 'Could not launch $url';
                // }*/
                //
                //      // MapsLauncher.launchQuery(url);
                //
                //       // MapsLauncher.launchCoordinates(
                //       //     lati, lngi, 'Google Map');
                //       //
                //       //                       openMapStreet(
                //       //     lati, lati);
                //
                //
                //       // openMapStreet(
                //       //     lati, lati);
                //
                //      // MapUtils.openMap(url);
                //
                //       // Navigator.push(
                //       //     context,
                //       //     MaterialPageRoute(
                //       //         builder: (context) => Browser(
                //       //           dashboardName: "Street View",
                //       //           dashboardURL: url,
                //       //         )));
                //
                //     },
                //     child: Container(
                //       padding: EdgeInsets.all(5),
                //       width: 36,
                //       height: 36,
                //       decoration: new BoxDecoration(
                //         color: Colors.white,
                //         shape: BoxShape.rectangle,
                //         // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                //         borderRadius: BorderRadius.circular(30),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black26,
                //             // blurRadius: 10.0,
                //             //offset: const Offset(0.0, 10.0),
                //           ),
                //         ],
                //       ),
                //       // color: Colors.white,
                //       //color: Color(0x99FFFFFF),
                //       child: Icon(FontAwesomeIcons.streetView,
                //         color: Color(0xff0D3D65),
                //         size: 20,
                //       ),
                //     ),
                //   ),
                // ),

                Positioned(

                  top: 260,
                  right: 16,
                  child: GestureDetector(
                    onTap: () async {


                      StaticVarMethod.lat=lati;
                      StaticVarMethod.lng=lngi;


                      // final uri = Uri(
                      //     scheme: "google.navigation",
                      //     // host: '"0,0"',  {here we can put host}
                      //     queryParameters: {
                      //       'q': '$lati, $lngi'
                      //     });
                      // if (await canLaunchUrl(uri)) {
                      //   await launchUrl(uri);
                      // } else {
                      //   debugPrint('An error occurred');
                      // }


                      final uri = Uri(
                          scheme: "google.streetview",
                          // host: '"0,0"',  {here we can put host}
                          queryParameters: {
                            'q': '$lati, $lngi'
                          });
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        debugPrint('An error occurred');
                      }


                      // const url = 'http://maps.google.com/maps?q=&layer=c&cbll=$lati,$lngi&cbp=11,direction,0,0,0';
                      //   if (await canLaunchUrl(url)) {
                      //     await launchUrl(url);
                      //   } else {
                      //     throw 'Could not launch $url';
                      //   }


                      // final url ='https://www.google.streetview:cbll=${StaticVarMethod.lat},${StaticVarMethod.lng}';
                      // if (await canLaunchUrl(Uri.parse(url))) {
                      //   await launchUrl(Uri.parse(url));
                      // } else {
                      //   throw 'Could not launch $url';
                      // }
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     fullscreenDialog: true,
                      //     builder: (context) => StreetViewPanoramaInitDemo(),
                      //   ),
                      // );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) =>
                      //           StreetViewPanoramaInitDemo()),
                      //   //   builder: (context) => tasks()),
                      // );

                      // setState(() {
                      //   isstreetview = !isstreetview;
                      //
                      // });


                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Center(

                              child: Icon(FontAwesomeIcons.streetView,
                                color: Color(0xff0D3D65),
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),

                (isstreetview)?Positioned(
                  top: 60,
                  left: 10,
                  child: Container(
                    height: 150,
                    width: 250,
                    child: streeview.FlutterGoogleStreetView(
                      /**
                       * It not necessary but you can set init position
                       * choice one of initPos or initPanoId
                       * do not feed param to both of them, or you should get assert error
                       */
                      //initPos: SAN_FRAN,

                      initPos: streeview.LatLng(lati, lngi),
                      //initPanoId: SANTORINI,

                      /**
                       *  It is worked while you set initPos or initPanoId.
                       *  initSource is a filter setting to filter panorama
                       */
                      initSource: streeview.StreetViewSource.outdoor,

                      /**
                       *  It is worked while you set initPos or initPanoId.
                       *  initBearing can set default bearing of camera.
                       */
                      initBearing: 30,

                      /**
                       *  It is worked while you set initPos or initPanoId.
                       *  initTilt can set default tilt of camera.
                       */
                      //initTilt: 30,

                      /**
                       *  It is worked while you set initPos or initPanoId.
                       *  initZoom can set default zoom of camera.
                       */
                      //initZoom: 1.5,

                      /**
                       *  iOS Only
                       *  It is worked while you set initPos or initPanoId.
                       *  initFov can set default fov of camera.
                       */
                      //initFov: 120,

                      /**
                       *  Web not support
                       *  Set street view can panning gestures or not.
                       *  default setting is true
                       */
                      //panningGesturesEnabled: false,

                      /**
                       *  Set street view shows street name or not.
                       *  default setting is true
                       */
                      //streetNamesEnabled: true,

                      /**
                       *  Set street view can allow user move to other panorama or not.
                       *  default setting is true
                       */
                      //userNavigationEnabled: true,

                      /**
                       *  Web not support
                       *  Set street view can zoom gestures or not.
                       *  default setting is true
                       */
                      zoomGesturesEnabled: false,

                      // Web only
                      //addressControl: false,
                      //addressControlOptions: ControlPosition.bottom_center,
                      //enableCloseButton: false,
                      //fullscreenControl: false,
                      //fullscreenControlOptions: ControlPosition.bottom_center,
                      //linksControl: false,
                      //scrollwheel: false,
                      //panControl: false,
                      //panControlOptions: ControlPosition.bottom_center,
                      //zoomControl: false,
                      //zoomControlOptions: ControlPosition.bottom_center,
                      //visible: false,
                      //onCloseClickListener: () {},
                      // Web only

                      /**
                       *  To control street view after street view was initialized.
                       *  You should set [StreetViewCreatedCallback] to onStreetViewCreated.
                       *  And you can using [controller] to control street view.
                       */
                      onStreetViewCreated: (streeview.StreetViewController controller) async {
                        /*controller.animateTo(
                          duration: 750,
                          camera: StreetViewPanoramaCamera(
                              bearing: 90, tilt: 30, zoom: 3));*/
                      },
                    ),
                  ),
                ):Container(),

                Positioned(
                  bottom: 280,
                  right: 10,

                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        setState(() {
                          if(speedo==0){
                            isParked = true;
                          }else{
                            isParked = true;
                            // Fluttertoast.showToast(
                            //     msg: "Parking Mode work On Stop Vehicles",
                            //     toastLength: Toast.LENGTH_LONG,
                            //     gravity: ToastGravity.CENTER,
                            //     timeInSecForIosWeb: 1,
                            //     backgroundColor: Colors.green,
                            //     textColor: Colors.white,
                            //     fontSize: 16.0);

                          }

                        });

                        submitFence();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: 50,
                      height: 50,
                      decoration: new BoxDecoration(
                        color:(isParked)?Colors.green:Colors.white,
                        shape: BoxShape.rectangle,
                        // borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Image.asset(
                          "assets/nepalicon/parking.png",
                          scale: 1,),
                    ),
                  ),
                ),

                ////////////left icons///////
                // Positioned(
                //   bottom: 460,
                //   left: 16,
                //   child: GestureDetector(
                //     onTap: () async {
                //
                //       setState(() {
                //         drawPolyline();
                //         drawPolyline2();
                //       });
                //
                //     },
                //     child: Container(
                //       padding: EdgeInsets.all(5),
                //       width: 36,
                //       height: 36,
                //       decoration: new BoxDecoration(
                //         color: Colors.white,
                //         shape: BoxShape.rectangle,
                //         //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                //         borderRadius: BorderRadius.circular(30),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black26,
                //             // blurRadius: 10.0,
                //             //offset: const Offset(0.0, 10.0),
                //           ),
                //         ],
                //       ),
                //       // color: Colors.white,
                //       //color: Color(0x99FFFFFF),
                //       child:   Icon(Icons.stacked_line_chart,
                //         //color: Colors.white,
                //         size: 25,
                //       ),
                //     ),
                //   ),
                // ),
                // Positioned(
                //   top: 300,
                //   right: 16,
                // //  margin: EdgeInsets.only(right: 10, top: 10),
                //   child: new RawMaterialButton(
                //     shape: new CircleBorder(),
                //     elevation: 15.0,
                //     fillColor: ruler ? Globals.appColor : Color(0xFFF6F6F6),
                //     child: Icon(
                //       FontAwesomeIcons.ruler,
                //       size: 15,
                //       color: ruler ? Color(0xFFF6F6F6) : Globals.appColor,
                //     ),
                //     onPressed: () async {
                //       setState(() {
                //         ruler = !ruler;
                //       });
                //       if (ruler) {
                //         LatLng latLngLast = markers.values.last.position;
                //         List<LatLng> latLngDistance = [];
                //         var location = await currentLocation.getLocation();
                //         try {
                //           var location = await currentLocation.getLocation();
                //           //LocationData currentLocation = await location.getLocation();
                //           latLngDistance.add(
                //               LatLng(location.latitude as double, location.longitude  as double));
                //           latLngDistance.add(latLngLast);
                //         } on Exception {}
                //         List<double> latitude = [];
                //         List<double> longitude = [];
                //         for (int i = 0; i < latLngDistance.length; i++) {
                //           latitude.add(latLngDistance[i].latitude);
                //           longitude.add(latLngDistance[i].longitude);
                //         }
                //         int distanceTemp = calculateDistance(
                //             latLngDistance.first.latitude,
                //             latLngDistance.first.longitude,
                //             latLngDistance.last.latitude,
                //             latLngDistance.last.longitude)
                //             .toInt();
                //         setState(() {
                //           _distancePolyLine.clear();
                //           _distancePolyLine.add(Polyline(
                //             polylineId: PolylineId(latLngDistance.last.toString()),
                //             visible: ruler,
                //             points: latLngDistance,
                //             jointType: JointType.round,
                //             endCap: Cap.roundCap,
                //             width: 2,
                //             startCap: Cap.roundCap,
                //             color: Colors.red,
                //           ));
                //           _controller.animateCamera(CameraUpdate.newCameraPosition(
                //               CameraPosition(target: latLngDistance.last, bearing: 0)));
                //           _controller.animateCamera(CameraUpdate.newLatLngBounds(
                //               getBounds(latitude, longitude), 100));
                //           distance = distanceTemp;
                //         });
                //       } else {
                //         _controller
                //             .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                //           zoom: 18,
                //           target: markers.values.last.position,
                //           bearing: double.parse(snapshot.data._angle),
                //         )));
                //       }
                //     },
                //   ),
                // ),
              /*  Positioned(
          bottom: 460,
          left: 16,
          child: GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        tripinfoselectionscreen()),
                //   builder: (context) => tasks()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(5),
              width: 36,
              height: 36,
              decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    // blurRadius: 10.0,
                    //offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              // color: Colors.white,
              //color: Color(0x99FFFFFF),
              child:   Icon(Icons.turn_sharp_right,
                //color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),*/

                Positioned(
                  bottom: 500,
                  left: 16,
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                lockscreenNew()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:   Icon(Icons.lock_person,
                        //color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
                Positioned(

                  bottom: 460,
                  left: 16,
                  child: GestureDetector(
                    onTap: () async {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => playbackselection()),
                      );

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child: Icon(Icons.play_circle,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),

                Positioned(

                  bottom: 420,
                  left: 16,
                  child: GestureDetector(
                    onTap: () async {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => kmdetail()),
                      );

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:  Image.asset(
                          "assets/speedoicon/assets_images_kmicon.png",
                          height: 20,
                          width: 20),/*Icon(Icons.refresh,
                  color: Colors.white,
                  size: 25,*/
                    ),
                  ),
                ),
                Positioned(

                  bottom: 380,
                  left: 16,
                  child: GestureDetector(
                    onTap: () async {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => vehicle_info()),
                      );

                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      width: 36,
                      height: 36,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        //borderRadius:BorderRadius.only(topLeft:Radius.circular(8),topRight:Radius.circular(8)),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // blurRadius: 10.0,
                            //offset: const Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      // color: Colors.white,
                      //color: Color(0x99FFFFFF),
                      child:  Image.asset(
                          "assets/images/icons8-info-popup-100.png",
                          height: 20,
                          width: 20),/*Icon(Icons.refresh,
                  color: Colors.white,
                  size: 25,*/
                    ),
                  ),
                ),
                (_statusbarLoading)?_showStatusPopup(devicemodel,boxImageSize)/*_showStatusPopup1()*/:_showvehiclestatus(),
                mainView()

              ]) : Center(
              child: Text("noData")  ): Center(child: CircularProgressIndicator(),) ,
        )
    );
  }
  Color? colormain = Colors.red.withOpacity(0.5);
  Widget mainView(){

    String status = fUpdateTime;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(padding: EdgeInsets.only(top: 5), child:
               Container(
              margin: EdgeInsets.only(left:20,right: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // border: Border.all(
                //   color: Colors.black,
                // ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: colormain!

              ),
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width / 1.02,
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(right: 8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(onTap: (){
                        Navigator.pop(context);
                      }, child:
                      Icon(Icons.arrow_back_ios,color: Colors.white, size: 30,))
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            StaticVarMethod.deviceName.toUpperCase(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: "Sofia",
                                fontWeight: FontWeight.w900,
                                fontSize: 14.0,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(status,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "Sofia",
                                  fontSize: 10.0,
                                  color: Colors.white,),
                              ),

                              // Text(('validity').tr(),style: TextStyle(
                              //     fontSize: 11.0,
                              //     color: MyColor.primaryColor),),
                              // Padding(padding: EdgeInsets.only(left: 5)),
                              // Text(devicesSettingsList![args.imei][33] != '0000-00-00' ? Util.dateToDays(devicesSettingsList![args.imei][33]).toString()+" days" : "-",
                              //   style: TextStyle(
                              //       fontSize: 11.0,
                              //       fontWeight: FontWeight.bold,
                              //       color: MyColor.primaryColor),),
                            ],
                          ),
                          // Text(device.data!.isNotEmpty ? device.data![0][6].toString() + " Km/hr" : "0 Km/hr",style: TextStyle(
                          //     fontSize: 11.0,
                          //     color: MyColor.primaryColor),),
                        ],
                      )
                    ],
                  )
                ],
              )
          )
          ),
        ),
      ],
    );
  }




  void getToMyLocation() async {
    var location = await currentLocation.getLocation();
    try {

      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          zoom: 18, target: LatLng(location.latitude ?? 0.0, location.longitude?? 0.0))));
    } on Exception {}
  }
  Widget speedometer() {


    return   Positioned(
        top: 70,
        left: 0,
        right: 0,
        child:  Speedometer(
          size:50,
          minValue: 0,
          maxValue: 160,
          currentValue:speedo!,
          barColor: Colors.black87,
          pointerColor: Colors.red,
          displayText: ""+speedo.toString()+" km",
          displayTextStyle: TextStyle(fontSize: 9, color: Colors.black,fontFamily: 'digital_font',fontWeight: FontWeight.bold ),
          displayNumericStyle: TextStyle(fontSize: 9, color: Colors.red,fontFamily: 'digital_font',fontWeight: FontWeight.bold,height: 40),
          onComplete: (){
            print("ON COMPLETE");
          },
        )
    );
  }




  Widget buildMap() {

    final googleMap = StreamBuilder<List<Marker>>(
        stream: mapMarkerStream,
        builder: (context, snapshot) {
          return GoogleMap(
            gestureRecognizers: Set()
              ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
              ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
              ..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()))
              ..add(Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer())),
            mapType: _currentMapType,
            trafficEnabled: _trafficEnabled,
            initialCameraPosition: _initialRegion,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: currentMapStatus,
            zoomControlsEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(0,20),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
        //  polylines:  Set<Polyline>.of(polylines.values),
            polylines:(ruler)?_distancePolyLine:Set<Polyline>.of(polylines.values),
            markers: Set<Marker>.of(snapshot.data ?? []),
            padding: EdgeInsets.all(50),
            circles: _circles,
          );
        });

    return Stack(
      children: <Widget>[
        Container(
            child:googleMap
        ),
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 50, 5, 0),
        //   child: Align(
        //     alignment: Alignment.topRight,
        //     child: Column(
        //       children: <Widget>[
        //         Padding(
        //           padding: const EdgeInsets.fromLTRB(0, 30, 5, 0),
        //           child: Align(
        //             alignment: Alignment.topRight,
        //             child: Column(
        //               children: <Widget>[
        //                 FloatingActionButton(
        //                   heroTag: "mapType",
        //                   onPressed: _onMapTypeButtonPressed,
        //                   materialTapTargetSize: MaterialTapTargetSize.padded,
        //                   backgroundColor: _mapTypeBackgroundColor,
        //                   foregroundColor: _mapTypeForegroundColor,
        //                   mini: true,
        //                   child: const Icon(Icons.map, size: 30.0),
        //                 ),
        //                 FloatingActionButton(
        //                   heroTag: "traffic",
        //                   onPressed: _trafficEnabledPressed,
        //                   mini: true,
        //                   materialTapTargetSize: MaterialTapTargetSize.padded,
        //                   backgroundColor: _trafficBackgroundButtonColor,
        //                   foregroundColor: _trafficForegroundButtonColor,
        //                   child: const Icon(Icons.traffic, size: 30.0),
        //                 ),
        //                 FloatingActionButton(
        //                   heroTag: "route",
        //                   onPressed: () async{
        //                     String origin = "device.data![0][2].toString()"; // lat,long like 123.34,68.56
        //                     if (Platform.isAndroid) {
        //                       String query = Uri.encodeComponent(origin);
        //                      String url =
        //                       "https://www.google.com/maps/search/?api=1&query=$query";
        //                       await launch(url);
        //                     } else {
        //                       String urlAppleMaps =
        //                       'https://maps.apple.com/?q=$origin';
        //                       String url =
        //                       "comgooglemaps://?saddr=&daddr=$origin&directionsmode=driving";
        //                       if (await canLaunch(url)) {
        //                     await launch(url);
        //                     } else {
        //                     if (await canLaunch(url)) {
        //                     await launch(url);
        //                     } else if (await canLaunch(
        //                     urlAppleMaps)) {
        //                     await launch(urlAppleMaps);
        //                     } else {
        //                     throw 'Could not launch $url';
        //                     }
        //                     throw 'Could not launch $url';
        //                     }
        //                   }
        //                   },
        //                   mini: true,
        //                   materialTapTargetSize: MaterialTapTargetSize.padded,
        //                   backgroundColor: Colors.white,
        //                   foregroundColor: MyColor.primaryColor,
        //                   child: const Icon(Icons.directions, size: 30.0),
        //                 ),
        //
        //                 // FloatingActionButton(
        //                 //   heroTag: "sensors",
        //                 //   onPressed: (){
        //                 //     Navigator.pushNamed(context, "/sensorsScreen",
        //                 //         arguments:DeviceManageArguments(args.imei));
        //                 //   },
        //                 //   mini: true,
        //                 //   materialTapTargetSize: MaterialTapTargetSize.padded,
        //                 //   backgroundColor: Colors.white,
        //                 //   foregroundColor: MyColor.primaryColor,
        //                 //   child: const Icon(Icons.sensors_sharp, size: 30.0),
        //                 // ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),




      ],
    );
  }


  Widget _showStatusPopup(deviceItems devicemodel, double boxImageSize) {


    String other =devicemodel.deviceData!.traccar!.other.toString();
    String ignition="true";
    String enginehours="0h";
    String sat="9";
    String totaldistance="0";
    String distance="0";

    // <info><event>0</event><sat>13</sat><hdop>0.9</hdop><odometer>678030</odometer>
    // <status>61</status><ignition>false</ignition><input>0</input><output>0</output>
    // <power>12.51</power><battery>4.07</battery><adc2>0</adc2><adc3>0</adc3><sequence>80</sequence>
    // <distance>0</distance><totaldistance>639240.95</totaldistance><motion>false</motion>
    // <valid>true</valid><enginehours>51916</enginehours><gsmsignal>13</gsmsignal></info>

    if(other.contains("<ignition>")){
      const start = "<ignition>";
      const end = "</ignition>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      ignition = other.substring(startIndex + start.length, endIndex);
    }
    if(other.contains("<enginehours>")){
      const start = "<enginehours>";
      const end = "</enginehours>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      int hours = int.parse(other.substring(startIndex + start.length, endIndex));
      enginehours= (hours/3600).toStringAsFixed(2);

    }
    if(other.contains("<sat>")){
      const start = "<sat>";
      const end = "</sat>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      sat = other.substring(startIndex + start.length, endIndex);
    }
    if(other.contains("<totaldistance>")){
      const start = "<totaldistance>";
      const end = "</totaldistance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      double dis = double.parse(other.substring(startIndex + start.length, endIndex));
      totaldistance= (dis/1000).toStringAsFixed(2);
     // totaldistance = other.substring(startIndex + start.length, endIndex);
    }
    if(other.contains("<distance>")){
      const start = "<distance>";
      const end = "</distance>";
      final startIndex = other.indexOf(start);
      final endIndex = other.indexOf(end, startIndex + start.length);
      distance = other.substring(startIndex + start.length, endIndex);
    }
    double imageSize = MediaQuery.of(context).size.width / 25;
    return (_statusbarLoading)?Positioned(
      bottom: 20,
      right: 10,
      left: 10,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              Container(
                //margin: EdgeInsets.fromLTRB(12, 6, 12, 6),

                child: Row(
                    children: [
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.fromLTRB(12, 6, 12, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child:  Container(
                                      // margin: EdgeInsets.only(top: 5),
                                      child: Text(''+/*StaticVarMethod.imei*/StaticVarMethod.deviceName,
                                          style: TextStyle(
                                              fontSize: 10,
                                              //height: 0.8,
                                              // fontFamily: 'digital_font'
                                              fontWeight: FontWeight.bold
                                          )),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child:                Container(

                                      child: GestureDetector(
                                          onTap: () {
                                            if (mounted) {
                                              setState(() {
                                                if(_statusbarLoading){
                                                  _statusbarLoading = false;
                                                }else{
                                                  _statusbarLoading = true;
                                                }

                                              });
                                            }
                                            // Fluttertoast.showToast(msg: 'Down', toastLength: Toast.LENGTH_SHORT);

                                          },
                                          child: Icon(Icons.arrow_drop_down_sharp,
                                              color: _mainColor, size: 40.0)

                                      ),
                                    ),
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child:  Container(
                                      // margin: EdgeInsets.only(top: 5),
                                      child: Text( (speedo! > 0)
                                          ? 'Moving '+fstopDuration
                                          : 'Stop '+fstopDuration,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: (speedo! >0)? Colors.green:Colors.grey,
                                              //height: 0.8,
                                              // fontFamily: 'digital_font'
                                              fontWeight: FontWeight.bold
                                          )),
                                    ),
                                  )
                                ],
                              )
                          )
                      ),

                    ]
                ),
              ),

            /*  (devicemodel.sensors!.isNotEmpty)?
              Container(

                  height:(devicemodel.sensors!.length>5)? 130:60,

                  child:  GridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    primary: false,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 8,
                    crossAxisCount: 5,
                    children: List.generate( devicemodel.sensors!.length, (int index) {
                      return GridItem(devicemodel.sensors![index]);

                    }),
                  )
              ):Container(),*/
              Container(
                  margin: EdgeInsets.only(bottom: 5),
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
                                  padding: EdgeInsets.all(8),
                                  child: Column(children: <Widget>[
                                    //Icon(Icons.engineering,size:imageSize),
                                    Image.asset("assets/sensorsicon/engineon.png",
                                        height: imageSize, width: imageSize),
                                    Text('Ignition',
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1.5,
                                            color: SOFT_GREY)),
                                    Text(
                                        (ignition.contains("true"))
                                            ? "On"
                                            : "Off",
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1,
                                            color: SOFT_GREY))
                                  ])),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                  padding: EdgeInsets.all(8),

                                  /*  decoration: new BoxDecoration(
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
                                  child: Column(children: <Widget>[
                                    Image.asset("assets/sensorsicon/locationon.png",
                                        height: imageSize, width: imageSize),
                                    Text('GPS',
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1.5,
                                            color: SOFT_GREY)),
                                    /*(productData.params?.gpslev != null)
                                        ? Text('${productData.params!.gpslev}',
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1,
                                            color: SOFT_GREY))
                                        :*/ Text(sat,
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1,
                                            color: SOFT_GREY))
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
                      //
                      //         },
                      //         child: Container(
                      //             padding: EdgeInsets.all(8),
                      //
                      //             /* decoration: new BoxDecoration(
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
                      //             ),*/
                      //             // color: Colors.white,
                      //             //color: Color(0x99FFFFFF),
                      //             child: Column(children: <Widget>[
                      //               Image.asset(
                      //                   "assets/sensorsicon/speedometeron.png",
                      //                   height: imageSize,
                      //                   width: imageSize),
                      //               Text('Odometer',
                      //                   style: TextStyle(
                      //                       fontSize: 7,
                      //                       height: 1.5,
                      //                       color: SOFT_GREY)),
                      //               Text('' + totaldistance + " km",
                      //                   style: TextStyle(
                      //                       fontSize: 7,
                      //                       height: 1,
                      //                       color: SOFT_GREY))
                      //             ])),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Expanded(
                      //   child: Column(
                      //     children: <Widget>[
                      //       GestureDetector(
                      //         onTap: () {
                      //
                      //
                      //           //_onMapTypeButtonPressed();
                      //         },
                      //         child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             child: Column(children: <Widget>[
                      //               Image.asset(
                      //                   "assets/sensorsicon/connectedon.png",
                      //                   height: imageSize,
                      //                   width: imageSize),
                      //               Text('GSM Level',
                      //                   style: TextStyle(
                      //                       fontSize: 7,
                      //                       height: 1.5,
                      //                       color: SOFT_GREY)),
                      //                Text('NaN',
                      //                   style: TextStyle(
                      //                       fontSize: 7,
                      //                       height: 1,
                      //                       color: SOFT_GREY))
                      //             ])),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {

                              },
                              child: Container(
                                  padding: EdgeInsets.all(8),

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
                                  child: Column(children: <Widget>[
                                    Image.asset("assets/sensorsicon/hour24on.png",
                                        height: imageSize, width: imageSize),
                                    Text('Eng Hour',
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1.5,
                                            color: SOFT_GREY)),
                                    Text(enginehours+' h' /*+ productData.engineHours.toString()*/,
                                        style: TextStyle(
                                            fontSize: 7,
                                            height: 1,
                                            color: SOFT_GREY))
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
                      //
                      //
                      //           //_onMapTypeButtonPressed();
                      //         },
                      //         child: Container(
                      //             padding: EdgeInsets.all(8),
                      //
                      //             /* decoration: new BoxDecoration(
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
                      //             ),*/
                      //             // color: Colors.white,
                      //             //color: Color(0x99FFFFFF),
                      //             child: Column(children: <Widget>[
                      //               Image.asset("assets/sensorsicon/batteryon.png",
                      //                   height: imageSize, width: imageSize),
                      //               Text('Battery',
                      //                   style: TextStyle(
                      //                       fontSize: 7,
                      //                       height: 1.5,
                      //                       color: SOFT_GREY))
                      //             ])),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  )),


              Container(
                  decoration: new BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.rectangle,
                    borderRadius:BorderRadius.only(bottomLeft:Radius.circular(15),bottomRight:Radius.circular(15)),
                    // borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        //blurRadius: 10.0,
                        //offset: const Offset(0.0, 10.0),
                      ),
                    ],
                  ),
                  child:
                  GestureDetector(
                      onTap: () async {

                        MapsLauncher.launchCoordinates(
                            lati, lngi, 'Google Map');
                        //final url ='https://www.google.com/maps/search/?api=1&query=${lati},${lngi}';
                        //MapUtils.openMap(url);

                        /*    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                      } else {
                      throw 'Could not launch $url';
                      }*/
                        // address = "Loading....";
                        //setState(() {});
                        //getAddress(lati,lngi);\

                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => Browser(
                        //           dashboardName: "Location",
                        //           dashboardURL: url,
                        //         )));
                      },
                      child: new Row(children: <Widget>[
                        Container(
                            margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.only(left: 5.0),

                            child: Icon(Icons.location_on_outlined,
                                color: CustomColor.primaryColor, size: 22.0)),
                        Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),

                        Flexible(
                          child: new Container(
                            padding: new EdgeInsets.only(right: 13.0),
                            child: new Text(
                              address,
                              overflow: TextOverflow.ellipsis,
                              style: new TextStyle(
                                fontSize: 13.0,
                                fontFamily: 'Roboto',
                                color: new Color(0xFF212121),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        /* Expanded(
                          child: Text(address,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis))*/
                      ]))
              ),



            ],
          ),
        ),
      ),
    ):_showvehiclestatus();


  }

  Widget _showvehiclestatus() {

    return Positioned(
      bottom: 30,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          // padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 40),

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.fromLTRB(6, 10, 6, 1),
                  padding:EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: GestureDetector(
                      onTap: () {

                        setState(() {
                          if(_statusbarLoading){
                            _statusbarLoading= false;
                          }else{
                            _statusbarLoading= true;
                          }

                        });
                       // Fluttertoast.showToast(msg: 'Up', toastLength: Toast.LENGTH_SHORT);

                      },
                      child: Icon(Icons.arrow_circle_up,
                          color: _mainColor, size: 40.0)

                  )
              ),


            ],
          ),
        ),
      ),
    );




  }
  Widget _showStatusPopup1() {

    var devicelist= devicesList.where((i) => i.deviceData!.imei!.contains(StaticVarMethod.imei)).single;

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 0),

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //  margin: EdgeInsets.fromLTRB(6, 1, 6, 1),

                child: Row(
                    children: [
                      Expanded(
                          child:Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              elevation: 0,
                              color: Colors.white,
                              child: Container(
                                //margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ClipRRect(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                          child: Image.asset("assets/images/Address.png", height: 25,width: 25)),

                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 20,right: 25,top: 5,bottom: 15),

                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  address = "Loading....";
                                                 // setState(() {});
                                                  getAddress(lati,lngi);
                                                },
                                                child:
                                                RichText(
                                                  maxLines: 5,
                                                  //textAlign: TextAlign.start,
                                                  overflow: TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                      text:address,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xff8E8E8E),
                                                        //fontWeight: FontWeight.bold
                                                      ),
                                                      children: [
                                                        /* TextSpan(
                text:eventList[index].message.toString() == "null" ? "" : eventList[index].message.toString(),
                style: TextStyle(

                    fontWeight: FontWeight.w400),
              )*/
                                                      ]
                                                  ),
                                                ),/*Text(address,
                                                  style: TextStyle(
                                                      fontSize: 12, color: Colors.blue),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis)*/
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                    ],
                                  )
                              ))
                      )
                    ]
                ),
              ),


              (devicelist.sensors!.isNotEmpty)?
              Container(

                  height:(devicelist.sensors!.length>5)? 170:100,

                  child:  GridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    primary: false,
                    childAspectRatio: 1,
                    shrinkWrap: true,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 8,
                    crossAxisCount: 5,
                    children: List.generate( devicelist.sensors!.length, (int index) {
                      return GridItem(devicelist.sensors![index]);

                    }),
                  )
              )
                  : Center(

                child:  Container(
                    margin: EdgeInsets.fromLTRB(20, 6, 1, 6),
                    height: 50,
                    width: 45,
                    decoration:  BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2.0,
                          offset:  Offset(0.5, 4.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0,0 ),
                          child:ClipRRect(
                              child: Image.asset("assets/sensorsicon/engineon.png", height: 13,width: 13,
                                color: Color(0xff0D3D65),)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                margin: EdgeInsets.only(top: 0),
                                child: Text('Ignition',
                                  style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff0D3D65),
                                  ),),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 2),
                                child: Text((speedo! > 0)?'ON':'OFF',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xff0D3D65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),

            ],
          ),
        ),
      ),
    );




  }

  Widget GridItem(Sensors model){
    return Container(
        padding: EdgeInsets.all(8),
        decoration:  BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2.0,
              offset:  Offset(0.5, 4.0),
            ),
          ],
        ),
        child:   Column(
            children: <Widget>[

              model.type
                  .toString()
                  .toLowerCase() ==
                  'ignition'
                  ? Image.asset("assets/sensorsicon/engineon.png",  height: 16,color: themeDark,)
                  : model.type
                  .toString()
                  .toLowerCase() ==
                  'odometer'
                  ? Image.asset("assets/sensorsicon/speedometeron.png",height: 16)
                  : model.type
                  .toString()
                  .toLowerCase() ==
                  'battery'
                  ? Icon(
                FontAwesomeIcons.batteryFull, size: 16,color:themeDark,) :

              model.type
                  .toString()
                  .toLowerCase() ==
                  'charge'
                  ? Icon(
                Icons.battery_charging_full, size: 16,color:themeDark,)
                  : model.type
                  .toString()
                  .toLowerCase() ==
                  'engine lock'
                  ? Icon(
                Icons.hourglass_bottom_rounded, size: 16,color:themeDark,) :
              model.type
                  .toString()
                  .toLowerCase() ==
                  'gps'
                  ? Icon(
                Icons.gps_fixed_outlined, size: 16,color:themeDark,) :
              model.type
                  .toString()
                  .toLowerCase() ==
                  'gsm'
                  ? Image.asset("assets/sensorsicon/connectedon.png",height: 16,color: themeDark,):
              model.type
                  .toString()
                  .toLowerCase() ==
                  'moving'
                  ? Icon(Icons.moving_outlined, size: 16,color:themeDark,) :
              model.type
                  .toString()
                  .toLowerCase() ==
                  'gps starting km'
                  ? Icon(
                Icons.gps_fixed_outlined, size: 16,color:themeDark,) :

              model.type
                  .toString()
                  .toLowerCase() ==
                  'temp'
                  ? Icon(
                FontAwesomeIcons.temperatureLow, size: 16,color:themeDark,)
                  : model.type
                  .toString()
                  .toLowerCase() ==
                  'engine_hours'
                  ? Icon(Icons.alarm, size: 16,color:themeDark,)
                  : Icon(Icons.charging_station, size: 16,color:themeDark,),
              //Icon(Icons.engineering,size:imageSize),
              // Image.asset("assets/sensorsicon/engineon.png", height: imageSize,width: imageSize),
              Text(model.name.toString(),  style: TextStyle(
                  fontSize: 6,height: 1.5, color: themeDark)),
              Text("${model.value.toString()}",  style: TextStyle(
                  fontSize: 7,height: 1, color: themeDark))
            ]
        )
    );
  }


  static Future<void> openMapStreet(double latitude, double longitude) async {
  //  String googleUrl = 'google.streetview:cbll=$latitude,$longitude';
    String googleUrl = 'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=%s,%s&heading=%s&pitch=%s&fov=%s=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }



  LatLngBounds getBounds(List<double> latitude, List<double> longitude) {
    var lngs = longitude;
    var lats = latitude;

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    return bounds;
  }

  String fencename="";
  //geofences
  void submitFence() {
    fencename="";
    // _showProgress(true);
    var random = Random();
    int randomNumber =  100000 + random.nextInt(900000);// // Generates a random integer between 100000 and 999999
    print('Random number: $randomNumber');

    fencename="ParkingFence$randomNumber "+StaticVarMethod.deviceName;

    Map<String, String> geoPoint = <String, String>{
      'lat': _markers.last.position.latitude.toString(),
      'lng': _markers.last.position.longitude.toString(),
    };

    Map<String, String> requestBody = <String, String>{
      'name': fencename,
      'polygon_color': "#c191c4",
      'polygon': '',
      'type': 'circle',
      'center': json.encode(geoPoint),
      'radius': "10",
    };


    gpsapis.addGeofence(requestBody).then((value) => {

      print(requestBody),
      getFences(),
      // Fluttertoast.showToast(
      //     msg: "Fence Added Successfully",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.green,
      //     textColor: Colors.white,
      //     fontSize: 16.0),

      //_showProgress(false)
    });
  }
  List<Gefanceparkmodel> fenceList = [];
  LatLng? _position;
  double lat=0.0;
  double lng=0.0;
  var center;
  void getFences() async {
    fenceList = [];
    gpsapis.getGeoFencesPark().then((value) => {
      if (value != null)
        {
          print(value),

          fenceList.addAll(value),
         // fenceList.last.name,
         // fenceList.last.id,

           fenceList.last.center!.lat,
          fenceList.last.center!.lng,


          fenceList.last.radius,
          updateNewCircle(fenceList.last.radius,fenceList.last.center!.lat,fenceList.last.center!.lng),
          addAlert(fenceList.last.id),
        }
      else
        {
          isLoading = false,
          setState(() {}),
        },
    });
  }
  void updateNewCircle(radius,lat,lng) {
    _circles = Set<Circle>();


    setState(() {
      _circles.add(Circle(
          circleId: CircleId("circle"),
          fillColor: Color(0x40d31818),
          strokeColor: Color(0),
          strokeWidth: 2,
          center: LatLng(double.parse(lat),double.parse(lng)),
          radius: 10));
    });
  }

  void addAlert(id) {

    String request ="&name=$fencename&type=geofence_out&&zone=0&geofences[]=$id&devices[]="+StaticVarMethod.deviceId;

print(request);
    gpsapis.addAlert(request).then((value) => {
    if (value.statusCode == 200)
    {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Parking Mode is ON'))),

      setState(() {}),
    }
    else
    {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Some Error in Pakring Mode is ON'))),
    }
    });
  }
}
