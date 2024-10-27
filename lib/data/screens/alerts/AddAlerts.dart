import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/device_data.dart';
import 'package:maktrogps/data/model/devices.dart';
import 'package:maktrogps/data/screens/AssignFenceScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/CustomColor.dart';
import '../../model/User.dart';

class AddAlertsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddAlertsPageState();
}

class _AddAlertsPageState extends State<AddAlertsPage> {
  Timer? _timer;
  SharedPreferences? prefs;
  User? user;
  bool isLoading = false;

  List<String> _devicesListstr=[];
  List<String> selectedDevices = [];
  List<String> types = [];
  String selectedType = "Types";
  TextEditingController _nameCtl = TextEditingController();
  TextEditingController _typeCtl = TextEditingController();

  void typeList() {
    types = <String>[
      "Overspeed",
      "Stop Duration",
      "Offline Duration",
      "Ignition Duration",
      "Idle Duration",
      "Geofence In",
      "Geofence Out",
      "Geofence In/Out",
      "Start of movement",
      "SOS",
      "Fuel(Fill/Theft)",
      "Driver change unauthorized"
    ];
  }

  @override
  initState() {
    super.initState();
    getUser();
    getFences();
    typeList();

  }



  void getFences() async {
    gpsapis.getGeoFences().then((value) => {
          if (value != null)
            {
              fenceList.addAll(value),
              setState(() {}),
            }
          else
            {
              isLoading = false,
              setState(() {}),
            },
        });
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    String userJson = prefs!.getString("user")!;

    final parsed = json.decode(userJson);
    user = User.fromJson(parsed);
    setState(() {});
  }

  void addAlert() {
    _showProgress(true);
    List devices = [];
    devices.add(selectedDevices);
    String request;
    if (selectedType == "types" ||
        selectedType == "Start of movement" ||
        selectedType == "SOS" ||
        selectedType == "Fuel(Fill/Theft)" ||
        selectedType == "Driver change unauthorized") {
      request = "&name=${_nameCtl.text}&type=${selectedType.toLowerCase()}&" +
          devices[0].join("&");
    } else {
      if (selectedType == "Geofence In") {
        request =
            "&name=${_nameCtl.text}&type=geofence_in&&zone=0&${selectedFenceList.join("&")}&" +
                devices[0].join("&");
      } else if (selectedType == "Geofence Out") {
        request =
            "&name=${_nameCtl.text}&type=geofence_out&&zone=0&${selectedFenceList.join("&")}&" +
                devices[0].join("&");
      } else if (selectedType == "Geofence In/Out") {
        request =
            "&name=${_nameCtl.text}&type=geofence_inout&&zone=0&${selectedFenceList.join("&")}&" +
                devices[0].join("&");
      } else {
        request =
            "&name=${_nameCtl.text}&type=${selectedType.toLowerCase()}&${selectedType.toLowerCase()}=${_typeCtl.text}&" +
                devices[0].join("&");
      }
    }
    print(request);


    gpsapis.addAlert(request).then((value) => {
          if (value.statusCode == 200)
            {
              _showProgress(false),
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('alertCreated'.tr))),
              Navigator.of(context).pop(),
            }
          else
            {
              _showProgress(false),
            }
        });
  }

  Widget deviceCard(deviceItems device, BuildContext context, setState) {
    return Row(
      children: [
        Checkbox(
            value: selectedDevices.contains("devices[]=${device.id}"),
            onChanged: (val) {
              setState(() {
                if (val!) {
                  selectedDevices.add("devices[]=${device.id}");
                } else {
                  selectedDevices.remove("devices[]=${device.id}");
                }
              });
            }),
        Text(device.name!)
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void showFenceDialog(BuildContext context) {
    fenceList.clear();
    selectedFenceList.clear();
    bool loading = true;
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          if (fenceList.isEmpty) {
            gpsapis.getGeoFences().then((value) => {
                  if (value != null)
                    {
                      fenceList.addAll(value),
                      loading = false,
                      setState(() {}),
                    }
                  else
                    {
                      loading = false,
                      setState(() {}),
                    },
                });
          }
          return AssignFenceScreen(context, setState, loading);
        },
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => simpleDialog);
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
                'اضافة تنبيه',
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body:  loadView()

    );
  }

  Widget loadView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: _nameCtl,
            // decoration: InputDecoration(hintText: 'Alert      dbnghytfresw2QXDCFGBHNM,NMBV  .,.of(context)Name'.tr),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: const Text("النوع"),
        ),
        Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10),
            width: 500,
            child: DropdownButton<String>(
              hint: Text(selectedType != "Types" ? selectedType : "نوع التنبيه"),
              items: types.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            )),
        selectedType == "Geofence In" ||
                selectedType == "Geofence Out" ||
                selectedType == "Geofence In/Out"
            ? InkWell(
                onTap: () {
                  showFenceDialog(context);
                },
                child: Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: const Card(
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text("GeoFences")),
                        )),
                  ],
                ))
            : Container(),
        selectedType != "types"
            ? selectedType != "Start of movement"
                ? selectedType != "SOS"
                    ? selectedType != "Fuel(Fill/Theft)"
                        ? selectedType != "Driver change unauthorized"
                            ? selectedType != "Geofence In"
                                ? selectedType != "Geofence Out"
                                    ? selectedType != "Geofence In/Out"
                                        ? Container(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 10, left: 10),
                                            child: TextField(
                                              controller: _typeCtl,
                                              decoration: const InputDecoration(
                                                  hintText: "القيمة"),
                                            ))
                                        : Container()
                                    : Container()
                                : Container()
                            : Container()
                        : Container()
                    : Container()
                : Container()
            : Container(),
        Container(
          padding: const EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: const Text("الاجهزة"),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: StaticVarMethod.devicelist.length,
                itemBuilder: (context, index) {
                  final device = StaticVarMethod.devicelist[index];
                  return deviceCard(device, context, setState);
                })),
        FloatingActionButton.extended(
          onPressed: () {
            addAlert();
          },
          label: Text("save".tr),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 5))
      ],
    );
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
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 5),
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
