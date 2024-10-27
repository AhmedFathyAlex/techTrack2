
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:maktrogps/config/apps/images.dart';

import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/data/datasources.dart';
import 'package:maktrogps/data/model/events.dart';
import 'package:maktrogps/data/screens/notificationmapscreen.dart';
import 'package:maktrogps/ui/reusable/cache_image_network.dart';



class notificationscreen_new extends StatefulWidget {

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<notificationscreen_new> {



  var _isLoading = true;
  List<EventsData> eventList = [];


  @override
  initState() {
    _isLoading = true;
    //notiList = Consts.notiList;
    getnotiList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    //return noNotificationScreen();
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        /* iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),*/
        //systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: false,
        title: Center(child: Image.asset(Images.appBarLogoNew, height: 40),
        ),
        backgroundColor: Colors.white,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: eventList.length > 0
          ? listView()
          : (_isLoading)? Center(
        //   child: Text('No data found'),
        child: CircularProgressIndicator(color: Colors.blue,),
      ):noNotificationScreen(), /*Center(
                child: Text('No data found'),
    ) ,*/
    );

  }

  PreferredSizeWidget  appBar(){
    return AppBar(
      backgroundColor: Colors.white,
      //leading: IconButton(
      //  icon: Icon(Icons.arrow_back, color: Colors.black),
      //   onPressed: () =>   Navigator.pop(context),
      /*   onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
              // builder: (context) => BottomNavigation( loginModel: response)),
              builder: (context) => BottomNavigation()),
          );
        },*/
      //Navigator.of(context,rootNavigator: true).pop(),
      // ),
      title: Text("Notification",style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }
  Widget listView1(){
    return ListView(
        children: ListTile.divideTiles(
            color: Colors.deepPurple,
            tiles: eventList.map((item) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber,
                child: CachedNetworkImage(
                  imageUrl: 'http://116.58.56.123:8008/Content/EmpImg/'+item.id.toString()+'.jpg',
                  imageBuilder: (context, imageProvider) => Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.image),
                ),
              ),
              title: Text(item.name.toString()),
              subtitle: Text(item.message.toString()),

              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
            ))).toList());
  }

  Widget listView(){
    return ListView.builder(
        itemCount: eventList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              child: listViewItems( index),
              onTap: () => onTapped());
        });
    /*return ListView.builder(itemBuilder:(context,index){
      return listViewItems(index);
    },separatorBuilder: (context,index){
      return Divider(height: 0);
    }, itemCount: eventList.length);*/
  }

  onTapped() async {
    /* Consts.DocId=approvalModel.DocId;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GetApproval(loginModel: loginModel)),
    );*/
  }


  Widget listViewItems(int index){
    return  GestureDetector(
      onTap: (){
        StaticVarMethod.lat=StaticVarMethod.eventList[index].latitude as double;
        StaticVarMethod.lng=StaticVarMethod.eventList[index].longitude  as double;
        StaticVarMethod.deviceName=StaticVarMethod.eventList[index].deviceName.toString();
        StaticVarMethod.type=StaticVarMethod.eventList[index].type.toString();
        StaticVarMethod.message=StaticVarMethod.eventList[index].message.toString();
        StaticVarMethod.time=StaticVarMethod.eventList[index].time.toString();
        StaticVarMethod.speed=StaticVarMethod.eventList[index].speed.toString();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => notificationmapscreen()),
        );
      },
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.fromLTRB(6, 1, 6, 0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        prefixIcon(index),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 15,right: 30,top: 8,bottom: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                message(index),
                                timeAndDate(index),
                              ],
                            ),
                          ),
                        ),


                      ]
                  )
              )
          ),
        ],
      ),
    );
  }




/*  Widget listViewItems(int index){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prefixIcon(index),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message(index),
                  timeAndDate(index),
                ],
              ),
            ),
          ),
          DeleteIcon(index),
        ],
      ),
    );
  }*/

  Widget prefixIcon(int index){
    var empid=eventList[index].id;
    return Container(
      height: 45,
      width: 45,
      margin: EdgeInsets.only(top:15,left: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        color: Color(0xfff5f5f5),
      ),
      child: Image.asset("assets/images/danger.png", height: 18,width: 18,color: Color(0xff9e9e9e)),
      //  child: Icon(Icons.notifications,
      //      size: 25,
      //      color:Color(0xff9e9e9e)),
    );


  }

  Widget DeleteIcon(int index){
    return Container(
      /* margin: EdgeInsets.only( top: 2, bottom: 2),
      width: 30,
      height: 30,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _DeleteNotification(eventList[index].alertId!.toInt());
        },
      ),*/
    );


    /*  return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(Icons.notifications,
          size: 25,
          color:Colors.grey.shade700),
    );*/
  }


  Widget message(int index){
    double textsize=12;
    var msg=eventList[index].message.toString();

    return Container(
      padding: EdgeInsets.only(right: 1,top: 10,bottom: 5),
      child: Text(eventList[index].name.toString(),style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold
      )),
    );


  }

  Widget timeAndDate(int index){
    return Container(
      //margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.only(right: 10,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(eventList[index].deviceName.toString(),style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          )),
          Text(eventList[index].time.toString(),style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
          ),
          // Text(Jiffy(eventList[index].time).fromNow()/*+eventList[index].time.toString()*/,style: TextStyle(
          //   fontSize: 11,
          //   color: Colors.grey.shade700,
          // ),
          // ),
        ],
      ),
    );
  }


  _DeleteNotification(int Id) async {
    print("Delete Notification ");

    /*   RestDataSource api = new RestDataSource();
    var response;
    response = await api.deleteUserNotifications(Id);
    if (response.toString().contains("true")) {
      notiList.clear();
      getnotiList();

    } else {
      print(response);
    }*/
  }

  Future<void> getnotiList() async {
    print("notificationlist");
    _isLoading = true;
    //setState(() {});
    gpsapis api = new gpsapis();
    try {
      eventList = await api.getEventsList(StaticVarMethod.user_api_hash);
      if (eventList.isNotEmpty) {
        StaticVarMethod.eventList=eventList;
        _isLoading = false;
        setState(() {});
      }
      else {
        _isLoading = false;
        setState(() {});
      }
    }
    catch (e) {
     // Fluttertoast.showToast(msg: 'Not exist', toastLength: Toast.LENGTH_SHORT);
      _isLoading = false;
      setState(() {});
    }

  }

  Widget noNotificationScreen() {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: Center(
        child: Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 40.0,
          ),
        ),
      ),
    );

    // final image = Image.asset("assets/images/empty.png");

    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "No New Notification",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );
    final notificationText = Text(
      "You currently do not have any unread notifications.",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        color: Colors.grey.withOpacity(0.6),
      ),
      textAlign: TextAlign.center,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: 70.0,
          left: 30.0,
          right: 30.0,
          bottom: 30.0,
        ),
        height: deviceHeight,
        width: deviceWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            pageTitle,
            SizedBox(
              height: deviceHeight * 0.1,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ notificationHeader, notificationText],
            ),
          ],
        ),
      ),
    );
  }

/*  Future<void> getnotiList() async {
    print("notificationlist");
    _isLoading = true;
    setState(() {});
    RestDataSource api = new RestDataSource();
    try {
      notiList = await api.getUserNotifications(loginModel.UserID);
      if (notiList.isNotEmpty) {
        _isLoading = false;
        setState(() {});
      } else {
      }
    } catch (e) {
      // _showSnackBar("Not exist",0);
    }
  }*/

}
