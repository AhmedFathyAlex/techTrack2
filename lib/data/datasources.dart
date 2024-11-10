import 'dart:convert';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/PositionHistory.dart';
import 'package:maktrogps/data/model/Taskmodel.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:maktrogps/data/model/gefanceparkmodel.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/utils/Session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Alert.dart';
import 'model/GeofenceModel.dart';
import 'model/User.dart';
import 'model/devices.dart';
import 'model/loginModel.dart';
import 'package:http/http.dart' as http;

class gpsapis{


 // static final StaticVarMethod.baseurlall =StaticVarMethod.baseurlall;

  static final LOGIN_URL = StaticVarMethod.baseurlall + "/api/login";
  static final Devices_URL = StaticVarMethod.baseurlall + "/api/get_devices";
  static final History_URL = StaticVarMethod.baseurlall + "/api/get_history";
  static final Events_URL = StaticVarMethod.baseurlall + "/api/get_events";
  static final Address_URL = StaticVarMethod.baseurlall + "/api/geo_address";
  static final registerUrl = StaticVarMethod.baseurlall +"/api/register";



  static final InstPriceBySKUAuto_URL =
      StaticVarMethod.baseurlall + "/api/Mapi/InstPriceBySKUAuto";

  static final SupplierList_URL = StaticVarMethod.baseurlall + "/api/Mapi/GetSuppliers";
  static final GetAllBranchesDailySale_URL =
      StaticVarMethod.baseurlall + "/api/Mapi/GetAllBranchesDailySale";

  static Map<String, String> headers = {};


  static getDevices(String? user_api_hash) async {
    return Session.apiGet(StaticVarMethod.baseurlall + "/api/get_devices?lang=en&user_api_hash=$user_api_hash").then((dynamic res) {
      print(res.toString());
      var jsonData = json.decode(res.toString());
      try {
        List<deviceItems> list = [];
        for (var i = 0; i < jsonData.length; i++) {
          for (var p in Devices.fromJson(jsonData[i]).items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
      }
    });
  }

  static getDevicesList(String? user_api_hash) async {
    return Session.apiGet(StaticVarMethod.baseurlall + "/api/get_devices?lang=en&user_api_hash=$user_api_hash").then((dynamic res) {
      print(res.toString());
      var jsonData = json.decode(res.toString());
      try {
        List<deviceItems> list = [];
        for (var i = 0; i < jsonData.length; i++) {
          for (var p in Devices.fromJson(jsonData[i]).items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
      }
    });
  }



  Future<List<deviceItems>> getDevicesItems(String? user_api_hash)async {
    //headers['Accept'] = "application/json";
    String? udre=user_api_hash;
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall + "/api/get_devices?lang=en&user_api_hash=$user_api_hash"));
    if (response.statusCode == 200) {
      //print(response.body);
      //return Devices.fromJson(json.decode(response.body));
      //Iterable list = json.decode(response.body);
      // return list.map((model) => Devices.fromJson(model)).toList();
      var jsonData = json.decode(response.body);
      try {
        List<deviceItems> list = [];
        for (var i = 0; i < jsonData.length; i++) {
          for (var p in Devices.fromJson(jsonData[i]).items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
        List<deviceItems> list = [];
        return list;
      }
    } else {
      print(response.statusCode);
      List<deviceItems> list = [];
      return list;
    }
  }


  Future<http.Response> getlogin(String email, String password) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(Uri.parse(StaticVarMethod.baseurlall + "/api/login?email=$email&password=$password"));

    if (response.statusCode == 200) {

      var res= LoginModel.fromJson(json.decode(response.body));
      StaticVarMethod.user_api_hash=res.userApiHash;
      StaticVarMethod.username=email.toString();
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setBool("notival", true);
      return response;

    } else {
      print(response.statusCode);
      //LoginModel model =new LoginModel();
      return response;
    }
  }
/*   Future<List<Devices>> getDevices(String? user_api_hash) async {
    //headers['Accept'] = "application/json";
    final response = await http.get(Uri.parse(Devices_URL + "?lang=en&user_api_hash=$user_api_hash"));
    if (response.statusCode == 200) {
      print(response.body);
     // return Devices.fromJson(json.decode(response.body));
      Iterable list = json.decode(response.body);
      return list.map((model) => Devices.fromJson(model)).toList();
    } else {
      print(response.statusCode);
      List<Devices> list=[];
      return list;
    }
  }*/
  /*Future<List<Devices>> getDevices(String? user_api_hash)async {
    //headers['Accept'] = "application/json";
    String? udre=user_api_hash;
    final response = await http.get(Uri.parse(Devices_URL + "?lang=en&user_api_hash=$user_api_hash"));
    if (response.statusCode == 200) {
      //print(response.body);
      //return Devices.fromJson(json.decode(response.body));
      //Iterable list = json.decode(response.body);
      // return list.map((model) => Devices.fromJson(model)).toList();
      var jsonData = json.decode(response.body);
      try {
        List<Devices> list = [];
        list.clear();
        for (var i = 0; i < jsonData.length; i++) {
          Devices listModel = Devices.fromJson(jsonData[i]);
          list.add(listModel);
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
        List<Devices> list = [];
        return list;
      }
    } else {
      print(response.statusCode);
      List<Devices> list = [];
      return list;
    }
  }*/



  Future<List<EventsData>> getEventsList_new(String? user_api_hash) async {
    List<EventsData> list = [];

    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall + "/api/get_events?lang=en&user_api_hash=$user_api_hash"));
    if (response.statusCode == 200) {


      var jsonData = json.decode(response.body);
      print(jsonData);
      /*for (var i = 0; i < jsonData[1].items!.data!.length; i++) {
          list.add(jsonData[1].items!.data![i]);
        }*/
      var events = Events.fromJson(response);
      for (var i = 0; i < events.items!.data!.length; i++) {
        list.add(events.items!.data![i]);
      }
      return list;

    } else {
      print(response.statusCode);
      //LoginModel model =new LoginModel();
      return list;
    }
  }
  getEventsList(String? user_api_hash) async {
    return Session.apiGet(StaticVarMethod.baseurlall + "/api/get_events?lang=en&user_api_hash=$user_api_hash").then((dynamic res) {
      print(res.toString());
      var jsonData = json.decode(res.toString());
      try {
        List<EventsData> list = [];

        /*for (var i = 0; i < jsonData[1].items!.data!.length; i++) {
          list.add(jsonData[1].items!.data![i]);
        }*/
        var events = Events.fromJson(jsonData);
        for (var i = 0; i < events.items!.data!.length; i++) {
            list.add(events.items!.data![i]);
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
      }
    });
  }

  getHistoryTripList(String? user_api_hash) async {
    return Session.apiGet(StaticVarMethod.baseurlall + "/api/get_history?lang=en&user_api_hash=$user_api_hash&device_id=369&from_date=2022-08-13&from_time=00:00&to_date=2022-08-13&to_time=11:45").then((dynamic res) {
      print(res.toString());
      var jsonData = json.decode(res.toString());
      try {
        List<TripsItems> list = [];

        /*for (var i = 0; i < jsonData[1].items!.data!.length; i++) {
          list.add(jsonData[1].items!.data![i]);
        }*/
        var history = History.fromJson(jsonData);
        for (var i = 0; i < history.items!.length; i++) {
          list.add(history.items![i]);
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
      }
    });
  }
  getHistoryAllList(String? user_api_hash) async {
    return Session.apiGet(StaticVarMethod.baseurlall + "/api/get_history?lang=en&user_api_hash=$user_api_hash&device_id="+StaticVarMethod.deviceId+"&from_date="+StaticVarMethod.fromdate+"&from_time="+StaticVarMethod.fromtime+"&to_date="+StaticVarMethod.todate+"&to_time="+StaticVarMethod.totime+"").then((dynamic res) {
      print(res.toString());
      var jsonData = json.decode(res.toString());
      try {
        List<AllItems> list = [];

        /*for (var i = 0; i < jsonData[1].items!.data!.length; i++) {
          list.add(jsonData[1].items!.data![i]);
        }*/
        var history = History.fromJson(jsonData);
        for (var i = 0; i < history.items!.length; i++) {
          for (var p in history.items![i].items ?? []) {

            list.add(p);
          }
        }
        return list;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
      }
    });
  }

  static Future<History> getHistory(deviceId) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date="+StaticVarMethod.fromdate+"&from_time="+StaticVarMethod.fromtime+"&to_date="+StaticVarMethod.todate+"&to_time="+StaticVarMethod.totime+"&device_id="+deviceId+"")).timeout(const Duration(minutes: 5));
    if (response.statusCode == 200) {
      //print(response.body);
     // var jsonData = json.decode(response.body);
      // return Devices.fromJson(json.decode(response.body));
   try {


   /*  List<History> list = [];
     list.clear();
     for (var i = 0; i < jsonData.length; i++) {
       var jsondataitem=jsonData[i];
       History listModel = History.fromJson(jsonData[i]);
       list.add(listModel);
     }
     return list;*/
     var jsonData = json.decode(response.body.toString());
     var history = History.fromJson(jsonData);
     return history;
     /* Iterable list = json.decode(response.body);
      return list.map((model) => History.fromJson(model)).toList();*/
    } catch (Ex) {
    print(Ex);
    print("Error occurred");
    History model = new  History();
    return model;
    }
    } else {
      print(response.statusCode);
     /* List<History> list=[];
      return list;*/
      History model = new  History();
      return model;
    }
  }

  Future<Events> getEvents(String? user_api_hash) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall + "/api/get_events?lang=en&user_api_hash=$user_api_hash"));
    if (response.statusCode == 200) {
      //print(response.body);
      try {
        return Events.fromJson(json.decode(response.body));
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
        Events model = new  Events();
        return model;
      }
    } else {
      print(response.statusCode);
      Events model = new  Events();
      return model;
    }
  }



  static Future<PositionHistory?> getHistorynew(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall + "/api/get_history?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    print(response.request);
    if (response.statusCode == 200) {
      print(
          "dod${"$History_URL?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"}");
      return PositionHistory.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }


  static Future<http.Response> getGeocoder(lat, lng) async {
    headers['content-type'] = "application/x-www-form-urlencoded; charset=UTF-8";

    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall + "/api/geo_address?lat=$lat&lon=$lng&user_api_hash=" + StaticVarMethod.user_api_hash!),
        headers: headers);
    return response;
  }

  static Future<String> geocode(lat, lng) async {
    headers['content-type'] = "application/x-www-form-urlencoded; charset=UTF-8";

    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall + "/api/geo_address?lat=$lat&lon=$lng&user_api_hash=" + StaticVarMethod.user_api_hash!),
        headers: headers);
    return response.body.toString();
  }


  //reports


  static Future<RouteReport?> getReport(
      String deviceID, String fromDate, String toDate, int type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall +
        "/api/generate_report?user_api_hash=" +
        StaticVarMethod.user_api_hash! +
        "&date_from=" +
        fromDate +
        "&devices[]=" +
        deviceID +
        "&date_to=" +
        toDate +
        "&format=pdf" +
       // "&format=html" +

        "&type=" +
        type.toString()));
    if (response.statusCode == 200) {
      print(
          "monir${StaticVarMethod.baseurlall + "/api/generate_report?user_api_hash=" + StaticVarMethod.user_api_hash! + "&date_from=" + fromDate + "&devices[]=" + deviceID + "&date_to=" + toDate + "&format=pdf" + "&type=" + type.toString()}");
      var report= RouteReport.fromJson(json.decode(response.body));
      StaticVarMethod.reporturl= report.url.toString();

      return report;
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<RouteReport?> getKMReport(String deviceID, String fromDate,
      String toDate, int type, String toTime, String fromTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall +
        "api/generate_report?user_api_hash=${prefs.getString('user_api_hash')}&date_from=$fromDate&devices[]=$deviceID&date_to=$toDate&format=pdf&type=2&from_time=$fromTime&to_time=$toTime"));
    if (response.statusCode == 200) {
      print(StaticVarMethod.baseurlall +
          "api/generate_report?user_api_hash=${prefs.getString('user_api_hash')}&date_from=$fromDate&devices[]=$deviceID&date_to=$toDate&format=pdf&type=2&from_time=$fromTime&to_time=$toTime");
      return RouteReport.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<User?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall +
        "/api/get_user_data?user_api_hash=" +StaticVarMethod.user_api_hash!));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      print(response.statusCode);
      return null;
    }
  }

  // static Future<http.Response> changePassword(val) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   headers['content-type'] =
  //   "application/x-www-form-urlencoded; charset=UTF-8";
  //   print(json.encode(val));
  //   final response = await http.post(
  //       Uri.parse(StaticVarMethod.baseurlall +
  //           "/api/edit_alert?user_api_hash=" +StaticVarMethod.user_api_hash!),
  //       body: val,
  //       headers: headers);
  //   print(response.body);
  //   return response;
  // }

  // static Future<http.Response> changePassword(String val) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   headers['content-type'] =
  //   "application/x-www-form-urlencoded; charset=UTF-8";
  //   print(json.encode(val));
  //   final response = await http.post(
  //       Uri.parse(StaticVarMethod.baseurlall + "/api/change_password?user_api_hash=" +StaticVarMethod.user_api_hash!+"&lang=en&password="+val+"&password_confirmation="+val)
  //       //body: val,
  //      // headers: headers
  //   );
  //   print(response.body);
  //   return response;
  // }

  static changePassword(String val) async {
    String url=StaticVarMethod.baseurlall + "/api/change_password?user_api_hash=" +StaticVarMethod.user_api_hash!+"&lang=en&password="+val+"&password_confirmation="+val;

    print(url.toString());
    return Session.apiPost(url,"")
        .then((dynamic res) {
      print(res.toString());

      var responseBool = res;
      return responseBool;
    });
  }

  static Future<http.Response> activateFCM(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/fcm_token?user_api_hash=" +StaticVarMethod.user_api_hash! +
            "&token=" +
            token),
        headers: headers);

    print(response.body);
    print(response.body);
    return response;
  }
  static Future<http.Response> deactivateFCM(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/delete_fcm_token?user_api_hash=" +token),
        headers: headers);

    print(response.body);
    print(response.body);
    return response;
  }


  static Future<http.Response> activateAlert(val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    print(json.encode(val));
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/change_active_alert?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        body: val,
        headers: headers);
    print(response.body);
    return response;
  }


  static Future<List<Alert>?> getAlertList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/get_alerts?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        headers: headers);
    if (response.statusCode == 200) {
      print(response.body);
      Iterable list = json.decode(response.body)['items']['alerts'];
      if (list.isNotEmpty) {
        return list.map((model) => Alert.fromJson(model)).toList();
      } else {
        return null;
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }
  static Future<http.Response?> login(email, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(Uri.parse(
          StaticVarMethod.baseurlall + "/api/login?email=" + email + "&password=" + password));

      if (response.statusCode == 200) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
  }


  ////////////////commands//////////////
  static Future<http.Response?> getSavedCommands(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url=StaticVarMethod.baseurlall +
    "/api/get_device_commands?user_api_hash=" +
        StaticVarMethod.user_api_hash! +
        "&device_id=$id";
    try{
      final response = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 5));
      if (response.statusCode == 200) {

        return response;
      } else {
        print(response.statusCode);
        return null;
      }
    }catch(e){
      print(e);
      print(e);
    }

  }

  static Future<http.Response?> getSendCommands(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall +
        "/api/send_command_data?user_api_hash=" +
        StaticVarMethod.user_api_hash!));
    if (response.statusCode == 200) {
      return response;
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> sendCommands(body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/send_gprs_command?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        body: body,
        headers: headers);
    return response;
  }
  ////////////////Geofences//////////////

  static Future<List<Geofence>?> getGeoFences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/get_geofences?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['items']['geofences'];
      if (list.isNotEmpty) {
        return list.map((model) => Geofence.fromJson(model)).toList();
      } else {
        return null;
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<List<Gefanceparkmodel>?> getGeoFencesPark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/get_geofences?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['items']['geofences'];
      if (list.isNotEmpty) {
        return list.map((model) => Gefanceparkmodel.fromJson(model)).toList();
      } else {
        return null;
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }
  static Future<http.Response> addGeofence(fence) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/add_geofence?user_api_hash=" +
            StaticVarMethod.user_api_hash!),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateGeofence(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.put(
        Uri.parse(StaticVarMethod.baseurlall + "/api/geofences/" + id),
        body: fence,
        headers: headers);
    return response;
  }

  ////////////////devices//////////////
  static Future<http.Response> adddevice(name, imei,sim_number) async {
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/add_device?user_api_hash=" +
            StaticVarMethod.user_api_hash!+"&name="+name+"&imei="+imei+"&icon_id=2&min_moving_speed=5&min_fuel_fillings=7&min_fuel_thefts=5&tail_length=5&fuel_measurement_id=1&sim_number="+sim_number+"&installation_date=18-08-2023&msisdn=123456&device_model=enter device model&city=enter city&sales_person=sales_person&installer=installer&mobile_1=mobile_1&address=address&customer_name=customer_name"),
        headers: headers);
    return response;
  }

  static Future<http.Response> editdevice(device_id,name, imei) async {
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/edit_device?user_api_hash=" +
            StaticVarMethod.user_api_hash!+"&device_id="+device_id+"&name="+name+"&imei="+imei+"&icon_id=2&min_moving_speed=5&min_fuel_fillings=7&min_fuel_thefts=5&tail_length=5&fuel_measurement_id=1"),
        headers: headers);
    return response;
  }
  ////////////////Alerts//////////////
  static Future<http.Response> addalert(name, type, device,overspeed) async {
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/add_alert?user_api_hash=" +
            StaticVarMethod.user_api_hash!+"&name="+name+"&type="+type+"&devices[]="+device+"&overspeed="+overspeed+""),
        headers: headers);
    return response;
  }

  static Future<http.Response> addAlert(String request) async {
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall+
            "/api/add_alert?user_api_hash=${StaticVarMethod.user_api_hash!}&lang=en" +
                request),
        headers: headers);
    print(response.request);
    print(response.body);
    return response;
  }


  static Future<http.Response> destroyAlert(id) async {
    headers['content-type'] =
    "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/destroy_alert?user_api_hash=${StaticVarMethod.user_api_hash!}&lang=en&alert_id=" +
            id.toString()),
        headers: headers);
    print(response.request);
    return response;
  }

  static Future<http.Response> getRegister(
      String name, String email, String phone, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(registerUrl), body: {
      'name': name,
      'email': email,
      "phone" : phone,
      'password': password,
    });
    //log(response.request!.url.toString());
    //log(response.body.toString());
    if (response.statusCode == 200) {
      // call login api
      //loginwith(email, password);
      return response;
    } else {
      //LoginModel model =new LoginModel();
      return response;
    }
  }

  static Future<http.Response> sendwhatsappsms(String phone, String text) async {

    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse("http://track.smarttrack.com.pk:3001/api/message?token=dk_10164edc7d99448f9e8f388b2256bf14&phone=$phone&message=$text"),
        headers: headers);
    if (response.statusCode == 200) {

      return response;
    } else {
      print(response.statusCode);
      return response;
    }
  }



  ////////////////TASK//////////////

  static Future<Taskmodel> getTasks(deviceId) async {
    final response = await http.get(Uri.parse(StaticVarMethod.baseurlall+"/api/get_tasks?lang=en&user_api_hash=${StaticVarMethod.user_api_hash}")).timeout(const Duration(minutes: 5));
    if (response.statusCode == 200) {
      try {
        var jsonData = json.decode(response.body.toString());
        var history = Taskmodel.fromJson(jsonData);
        return history;
      } catch (Ex) {
        print(Ex);
        print("Error occurred");
        Taskmodel model = new  Taskmodel();
        return model;
      }
    } else {
      print(response.statusCode);
      Taskmodel model = new  Taskmodel();
      return model;
    }
  }
  static Future<String> AddTaskNew(deviceId, title, comment,pickup_address,delivery_address) async {
    headers['Accept'] = "application/json";

    try {
      Map<String, String> requestBody = <String, String>{
        'device_id': deviceId.toString(),
        'invoice_number': "464356456",
        'title': title,
        'priority': '1',
        'comment': comment,
        'status': '1',
        'pickup_address': pickup_address,
        'pickup_address_lat': '0.0',
        'pickup_address_lng': '0.0',

        'pickup_time_from': '2024-04-13 08:00:00',
        'pickup_time_to': '2024-04-13 12:00:00',
        'delivery_address': delivery_address,
        'delivery_address_lat': '0.0',
        'delivery_address_lng': '0.0',

        'delivery_time_from': '2024-04-13 12:00:00',
        'delivery_time_to': '2024-04-13 17:00:00'
      };
      final response = await http.post(Uri.parse(StaticVarMethod.baseurlall + "/api/add_task?user_api_hash=" + StaticVarMethod.user_api_hash!),
          body:requestBody, headers: headers
      );
      print(response);
      print(response);
      if (response.statusCode == 200) {

        return "Success";
      } else {
        print(response.statusCode);
        return "Fail";
      }
    }
    catch (Ex) {
      print(Ex);
      print("Error occurred");

      return "Execption";

    }

  }
  static Future<String> AddTask(deviceId, title, comment,type/*,pickup_address,pickup_address_lat,pickup_address_lng*/) async {
    headers['Accept'] = "application/json";

    try {
      Map<String, String> requestBody = <String, String>{
        'device_id':deviceId.toString(),
        'title':title,
        'comment':comment,
        'priority':'1',
        'status':'1',
        'pickup_address':'Biratnagar',
        'pickup_address_lat':'27.32423424',
        'pickup_address_lng':'87.325532434',
        'type': type
      };
      final response = await http.post(Uri.parse(StaticVarMethod.baseurlall + "/api/add_task?user_api_hash=" + StaticVarMethod.user_api_hash!),
          body:requestBody, headers: headers
      );
      print(response);
      print(response);
      if (response.statusCode == 200) {

        return "Success";
      } else {
        print(response.statusCode);
        return "Fail";
      }
    }
    catch (Ex) {
      print(Ex);
      print("Error occurred");

      return "Execption";

    }

  }


  ////////////////add sensors///////////////////////
  static Future<String> addsensors(device_id,odometer17) async {

    var request = http.MultipartRequest('POST', Uri.parse(StaticVarMethod.baseurlall+'/api/add_sensor?lang=en&user_api_hash=${StaticVarMethod.user_api_hash!}'));
    request.fields.addAll({
      'device_id': device_id,
      'sensor_name': 'Odometer',
      'sensor_type': 'odometer',
      'unit_of_measurement': 'km',
      'odometer_value_by': 'virtual_odometer',
      'odometer_value': odometer17,
      'odometer_value_unit': 'km'
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      return "Success";
    }
    else {
    print(response.reasonPhrase);
    return "Faild";
    }
  }
}

class RouteReport extends Object {
  int? status;
  String? url;
  RouteReport({this.status, this.url});

  RouteReport.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    url = json["url"];
  }
}




