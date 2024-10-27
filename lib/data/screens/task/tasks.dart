import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:maktrogps/config/apps/ecommerce/global_style.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/model/PositionHistory.dart';
import 'package:maktrogps/data/model/Taskmodel.dart';
import 'package:maktrogps/data/model/history.dart';
import 'package:maktrogps/mapconfig/CommonMethod.dart';
import 'package:http/http.dart' as http;
import 'package:maktrogps/data/datasources.dart';

class tasks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _tasksState();
}

class _tasksState extends State<tasks> {


  TextEditingController commentController = TextEditingController();
  TextEditingController _titleFieldController = TextEditingController();
  TextEditingController _commentFieldController = TextEditingController();
  TextEditingController _pickupaddressFieldController = TextEditingController();
  TextEditingController _pickupaddresslatFieldController = TextEditingController();
  TextEditingController _pickupaddresslngFieldController = TextEditingController();
  String? type="Business";
  int deviceId=0;
  List<String> _devicesListstr=[];
  String? _chosenValue1;

  List<Data> taskList = [];
  @override
  initState() {
    super.initState();
    getdeviesList();
    gettaskList();
  }

  Future<void> getdeviesList() async {
    _devicesListstr.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      _devicesListstr.add(StaticVarMethod.devicelist.elementAt(i).name!);
    }
    setState(() {
    });
  }
  Future<void> gettaskList() async {
    print("notificationlist");

    try {
      var list = await gpsapis.getTasks(StaticVarMethod.user_api_hash);

      for (var i = 0; i < list.items!.data!.length; i++) {
        taskList.add(list.items!.data![i]);
      }
      setState(() {});
    }
    catch (e) {
     // Fluttertoast.showToast(msg: 'Not exist', toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.home_filled),
                text: "New Trip",
              ),
              Tab(
                icon: Icon(Icons.account_box_outlined),
                text: "All Trips",
              ),
              // Tab(
              //   icon: Icon(Icons.alarm),
              //   text: "Alarm",
              // ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.white,
                      // border: Border(
                      //     bottom: BorderSide(
                      //       color: Colors.transparent,
                      //       width: 1.0,
                      //     )
                      // ),
                    ),
                    child:Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        //color: Colors.grey.shade900,
                        //shadowColor: Colors.pink,
                        child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child:
                            DropdownSearch(
                              items: _devicesListstr,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  // labelText: "Location",
                                  hintText: "Select Report",
                                ),
                              ),
                              onChanged: (dynamic value) {

                                    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                                      if (value != null) {
                                        if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                                          deviceId=StaticVarMethod.devicelist.elementAt(i).id;
                                          print("value: " + value);
                                          break;
                                        }
                                      }
                                    }
                                    setState(() {
                                      //_selectedReport = value;
                                    });


                              },
                              // selectedItem: "Tunisia",
                              // validator: (String? item) {
                              //   if (item == null)
                              //     return "Required field";
                              //   else if (item == "Brazil")
                              //     return "Invalid item";
                              //   else
                              //     return null;
                              // },
                            )

                            // DropdownSearch(
                            //   mode: Mode.MENU,
                            //   showSelectedItems: true,
                            //   items: _devicesListstr,
                            //   dropdownSearchDecoration: InputDecoration(
                            //     //labelText: "Location",
                            //     hintText: "Select Vehicle",
                            //   ),
                            //   onChanged: (dynamic value) {
                            //     for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
                            //       if (value != null) {
                            //         if (StaticVarMethod.devicelist.elementAt(i).name!.contains(value)) {
                            //           deviceId=StaticVarMethod.devicelist.elementAt(i).id;
                            //           print("value: " + value);
                            //           break;
                            //         }
                            //       }
                            //     }
                            //     setState(() {
                            //       //_selectedReport = value;
                            //     });
                            //
                            //   },
                            //   showSearchBox: true,
                            //   searchFieldProps: TextFieldProps(
                            //     cursorColor: Colors.red,
                            //   ),
                            //
                            // )
                        )),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: _titleFieldController,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),

                 /* Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: _commentFieldController,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Comment',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),*/

                  Container(
                    color: Color(0xffF8F7FC),
                    padding: EdgeInsets.only(left: 70, right: 70,bottom: 0,),
                    child: DropdownButtonHideUnderline(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: DropdownButton<String>(
                          isDense: false,
                          icon: Icon(Icons.keyboard_arrow_down_sharp),
                          value: _chosenValue1,
                          //elevation: 5,
                          style: TextStyle(color: Colors.black),
                          items: <String>[
                            'Business',
                            'Personal',

                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          hint: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              "Business",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          onChanged: (String? value) {
                            type=value;
                          },
                        ),
                      ),
                    ),
                  ),
             /*     Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: _pickupaddressFieldController,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Pickup Address',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: _pickupaddresslatFieldController,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Pickup Address lat',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:TextField(
                        controller: _pickupaddresslngFieldController,
                        onChanged: (String value) {
                        },

                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade500)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          labelText: 'Pickup Address lng',
                          labelStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                  ),*/
                  // Container(
                  //   margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                  //   padding: EdgeInsets.only(left: 10, right: 10),
                  //   child: TextFormField(
                  //       readOnly: false,
                  //       style: TextStyle(color: Colors.black),
                  //       keyboardType: TextInputType.multiline,
                  //       maxLines: 6,
                  //       controller: commentController,
                  //       decoration: InputDecoration(
                  //           isDense: true,
                  //           labelText: "Comment",
                  //           border: OutlineInputBorder()),
                  //       onChanged: (val) {
                  //         if (val.isNotEmpty) {
                  //         //  itemsrRemarks = val;
                  //         } else {
                  //          // itemsrRemarks = "";
                  //         }
                  //       }),
                  // ),
                  Container(

                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      // color: CustomColor.primaryColor,
                      onPressed: () {

                        _savetask();

                      },
                      child: Text("Save",
                          style: TextStyle(
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: listView()
            ),
            // Center(
            //   child: Icon(Icons.alarm),
            // )
          ],
        ),
      ),
    );
  }

  Widget listView(){

    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              child: listViewItems( index),
             // onTap: () => onTapped()
          );
        });
  }
  Widget listViewItems(int index){
    return
      GestureDetector(
          onTap: (){
          },
          child:
          Container(
              margin: EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //prefix
                        Container(
                          height: 45,
                          width: 45,
                          margin: EdgeInsets.only(top:15,left: 10),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Image.asset("assets/icon/truck-icon.png", height: 55,width: 55),

                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8,right: 30,top: 8,bottom: 15),

                            child: Column(
                              children: [
                                //DeleteIcon(index),
                                Container(
                                  padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
                                  child: RichText(
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        text:' ' +taskList[index].title.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
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
                                  ),
                                ),
                                Container(

                                  padding: EdgeInsets.only(right: 10,bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(taskList[index].type.toString(),style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]
                  )
              )
          )
      );
  }
  void _savetask() async {

    try {

      // Response result = await gpsapis.AddTask(
      //     _titleFieldController.text, _commentFieldController.text,_pickupaddressFieldController.text,_pickupaddresslatFieldController.text,_pickupaddresslngFieldController.text);

      String result = await gpsapis.AddTask(deviceId, _titleFieldController.text, "comment",type);
print(result);

      Fluttertoast.showToast(msg: 'Task Added Successful', toastLength: Toast.LENGTH_SHORT);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Task Added Successful'),
      //     backgroundColor: Colors.green,
      //   ),
      // );



    } catch (e) {
      Fluttertoast.showToast(msg: 'Error Occured', toastLength: Toast.LENGTH_SHORT);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Task Added Successful'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Something went wrong'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }
}