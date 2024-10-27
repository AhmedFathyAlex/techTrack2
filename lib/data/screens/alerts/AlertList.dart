import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maktrogps/data/screens/alerts/AddAlerts.dart';
import 'package:maktrogps/mapconfig/CustomColor.dart';
import 'package:maktrogps/model/Alert.dart';
import 'package:maktrogps/model/User.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AlertListPageState();
}

class _AlertListPageState extends State<AlertListPage> {
  Timer? _timer;
  SharedPreferences? prefs;
  User? user;
  bool isLoading = false;
  List<Alert> alertList = [
    Alert(type: 'test')
  ];

  @override
  initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String userJson = prefs!.getString("user")!;

    final parsed = json.decode(userJson);
    user = User.fromJson(parsed);
    getAlerts();
    setState(() {});
  }

  void removeAlert(Alert alert) {
    _showProgress(true);
    alertList.clear();

    Map<String, String> requestBody = <String, String>{
      'id': alert.id.toString(),
      'active': "false"
    };
    gpsapis.activateAlert(requestBody).then((value) => {
          if (value.statusCode == 200)
            {
              getAlerts(),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void activateAlert(Alert alert) {
    _showProgress(true);
    alertList.clear();
    alert.devices!.join(',');
    Map<String, String> requestBody = <String, String>{
      'id': alert.id.toString(),
      'active': "true"
    };
    gpsapis.activateAlert(requestBody).then((value) => {
          if (value.statusCode == 200)
            {
              getAlerts(),
              _showProgress(false),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  void getAlerts() async {
    _showProgress(true);
    gpsapis.getAlertList().then((value) {
      if (value != null) {
        alertList.addAll(value);
        _showProgress(false);
        setState(() {});
      } else {
        isLoading = false;
        setState(() {});
        _showProgress(false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('alertsNotFound'.tr)));
      }
      ;
    });
  }

  void deleteAlert(id) {
    _showProgress(true);
    gpsapis.destroyAlert(id).then((value) => {
          _showProgress(false),
          alertList.clear(),
          getAlerts(),
          setState(() {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Alert Created'.tr)));
          }),
        });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: CustomColor.primaryColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alerts'.tr,
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  //  builder: (context) => livetrack()),
                    builder: (context) => AddAlertsPage()),

              );

              // Navigator.pushNamed(context, "/addAlert")
              //     .then((value) => {alertList.clear(), getAlerts()});
            },
            child: Padding(
                padding: EdgeInsets.only(right: 5), child: Icon(Icons.add)),
          )
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
                itemCount: alertList.length,
                itemBuilder: (context, index) {
                  final alert = alertList[index];
                  return alertCard(alert, context);
                }))
      ]),
    );
  }

  Widget alertCard(Alert alert, BuildContext context) {
    return Card(
        elevation: 2.0,
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(children: <Widget>[
              InkWell(
                  onTap: () {},
                  child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                alert.name?? 'unKnown',
                                style: TextStyle(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                      value: alert.active.toString() == "1"
                                          ? true
                                          : false,
                                      onChanged: (value) {
                                        if (value!) {
                                          activateAlert(alert);
                                        } else {
                                          removeAlert(alert);
                                        }
                                      }),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteAlert(alert.id);
                                    },
                                  )
                                ],
                              )
                            ])
                      ])))
            ])));
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(('sharedLoading').tr)),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}

class AlertArguments extends Object {
  Alert? alertModel;
  int? deviceId;
  String? name;

  AlertArguments({this.alertModel, this.deviceId, this.name});
}
