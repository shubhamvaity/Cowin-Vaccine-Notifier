import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:http/http.dart' as http;
import 'models/CalenderByPin.dart';
import 'package:url_launcher/url_launcher.dart';

const EVENTS_KEY = "fetch_events";
List<String> alert = [];

// ["400004","COVISHIELD","2","age group"];
FlutterLocalNotificationsPlugin localNotifications;

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var androidInitialize =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  var iOSInitialize = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      android: androidInitialize, iOS: iOSInitialize);
  localNotifications = new FlutterLocalNotificationsPlugin();
  localNotifications.initialize(initializationSettings);

  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received: $taskId");
  var prefs = await SharedPreferences.getInstance();
  alert = prefs.getStringList('alert');
  print("Alert" + alert.toString());
  // var timestamp = DateTime.now();
  // _showNotificationHeadless();

  // Read fetch_events from SharedPreferences
  //var events = <String>[];
  List<List<String>> events = [];

  // SharedPreferences prefs;

  // List<String> keys = prefs.getKeys().toList();
  // for (var i = 0; i < keys.length; i++) {
  //   var json = prefs.getStringList(keys[i]);
  //   if (json != null) {
  //     events.add(json);
  //   }
  // }

  fetchSlotsHeadless(prefs, events, taskId, alert[1], alert[2], alert[3],
      pinCode: alert[0]);
  // Add new event.
  // events.insert(0, "$taskId@$timestamp [Headless]");

  // Persist fetch events in SharedPreferences
  // prefs.setString(EVENTS_KEY, jsonEncode(events));

  // if (taskId == 'flutter_background_fetch') {
  //   BackgroundFetch.scheduleTask(TaskConfig(
  //       taskId: "com.transistorsoft.customtask",
  //       delay: 5000,
  //       periodic: false,
  //       forceAlarmManager: false,
  //       stopOnTerminate: false,
  //       enableHeadless: true
  //   ));
  // }

  BackgroundFetch.finish(taskId);
}

// Future fetchSlotsHeadless(
//     var events, String taskId, String pinCode, String date) async {
//   events.insert(0, "[Headless]");
//   var fetchUrl =
//       "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=" +
//           pinCode +
//           "&date=" +
//           date;
//   var url = Uri.parse(fetchUrl);
//   final response = await http.get(url);
//   Autogenerated sd = Autogenerated.fromJson(jsonDecode(response.body));
//   var n = sd.sessions.length;

//   if (n > 0) {
//     events.insert(0, "SLOTS AVAILABLE (headless)" + "$taskId@${n.toString()}");
//     _showNotificationHeadless();
//   }
// }
Future fetchSlotsHeadless(SharedPreferences prefs, var events, String taskId,
    String vaccineType, String doseNo, String ageIp,
    {String pinCode = "000000"}) async {
  var time = DateTime.now();
  String urlDate = time.day.toString() +
      "-" +
      time.month.toString() +
      "-" +
      time.year.toString();
  var fetchUrl =
      "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=" +
          pinCode +
          "&date=" +
          urlDate;
  var url = Uri.parse(fetchUrl);
  final response = await http.get(url);
  CalenderByPin data = CalenderByPin.fromJson(jsonDecode(response.body));
  var noOfHospitals;
  if (data.centers != null) {
    noOfHospitals = data.centers.length;
  } else {
    noOfHospitals = 0;
  }

  print(fetchUrl);
  print("#ofHosp:" + noOfHospitals.toString());
  // print(data.centers[0].sessions[0].availableCapacity);

  List<List<String>> details = [];

  for (var i = 0; i < noOfHospitals; i++) {
    var noOfSessions = data.centers[i].sessions.length;

    List<String> temp = [];
    temp.add(data.centers[i].name);
    temp.add("Address : " +
        data.centers[i].address +
        ", " +
        data.centers[i].stateName);
    temp.add("Fee Type : " + data.centers[i].feeType);
// Structure : name,address,fee(with type),date,dose 1/2,vaccine type,age
    for (var j = 0; j < noOfSessions; j++) {
      if (doseNo == '1' &&
          data.centers[i].sessions[j].minAgeLimit.toString() == ageIp &&
          data.centers[i].sessions[j].availableCapacity > 0 &&
          data.centers[i].sessions[j].vaccine == vaccineType &&
          data.centers[i].sessions[j].availableCapacityDose1 > 0) {
        //show notifcn
        temp.add(data.centers[i].sessions[j].date);
        temp.add("Dose 1 Capacity : " +
            data.centers[i].sessions[j].availableCapacityDose1.toString());
        temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
        temp.add("Age : " + data.centers[i].sessions[j].minAgeLimit.toString());
      } else if (doseNo == '2' &&
          data.centers[i].sessions[j].minAgeLimit.toString() == ageIp &&
          data.centers[i].sessions[j].availableCapacity > 0 &&
          data.centers[i].sessions[j].vaccine == vaccineType &&
          data.centers[i].sessions[j].availableCapacityDose2 > 0) {
        temp.add(data.centers[i].sessions[j].date);
        temp.add("Dose 2 Capacity : " +
            data.centers[i].sessions[j].availableCapacityDose2.toString());
        temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
        temp.add("Age Limit : " +
            data.centers[i].sessions[j].minAgeLimit.toString());
      }
    }
    if (temp.isNotEmpty && temp.length > 3) {
      details.add(temp);
      events.insert(0, temp);
      // prefs.setStringList(i.toString(), temp);
      // _showNotificationHeadless();
      print(temp);
    }

    // events.insert(0, temp.toString());
    // print("---------------------------------------------------");
  }
  print("Headless Events List");
  print(events);
  if (details.isNotEmpty) {
    _showNotificationHeadless();
  }
}

Future _showNotificationHeadless() async {
  var androidDetails = new AndroidNotificationDetails(
    "channelId",
    "Local Notifcn",
    "This is Description",
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    // vibrationPattern: new Int64List(length),
    // sound: RawResourceAndroidNotificationSound("sound"),
    ongoing: true,
    styleInformation: BigTextStyleInformation(''),
  );

  var iosDetails = new IOSNotificationDetails();

  var generalNotificationDetails =
      new NotificationDetails(android: androidDetails, iOS: iosDetails);

  await localNotifications.show(
      0,
      "Slots Available at PIN Code : " + alert[0],
      "Vaccine : " +
          alert[1] +
          "\nDose No : " +
          alert[2] +
          "\nAge Group : " +
          alert[3] +
          " +",
      generalNotificationDetails);
}
// Future _showNotificationHeadless() async {
//   var androidDetails = new AndroidNotificationDetails(
//       "channelId", "headless Local Notifcn", "This is Description",
//       importance: Importance.high);

//   var iosDetails = new IOSNotificationDetails();

//   var generalNotificationDetails =
//       new NotificationDetails(android: androidDetails, iOS: iosDetails);

//   await localNotifications.show(
//     0,
//     "Headless Notif title",
//     "This is Details",
//     generalNotificationDetails,
//     payload: "this is payload",
//   );
// }

// void main() {
//   // Enable integration testing with the Flutter Driver extension.
//   // See https://flutter.io/testing/ for more info.
//   List<String> ips = ["400004", "COVISHIELD", "2"];
//   runApp(MyBgApp(ips));

//   // Register to receive BackgroundFetch events after app is terminated.
//   // Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
// }
var enableGlobal;
Future<void> initSetEnable(enabled) async {
  var pf2 = await SharedPreferences.getInstance();
  // enableGlobal = pf2.getString('enable');
  // var prefs = await SharedPreferences.getInstance();
  // prefs.setStringList("alert", ip);
  pf2.setString("enable", enabled.toString());
}

class MyBgApp extends StatefulWidget {
  final List<String> ip;
  MyBgApp(this.ip);
  @override
  _MyBgAppState createState() => new _MyBgAppState(ip);
}

List<List<String>> _events = [];

class _MyBgAppState extends State<MyBgApp> {
  // FlutterLocalNotificationsPlugin localNotifications;
  List<String> ip;
  _MyBgAppState(this.ip);
  bool _enabled = true;
  int _status = 0;
  // List<List<String>> _events = [];
  // List details = [];

  @override
  void initState() {
    super.initState();
    alert = ip;

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // List<List<String>> _events = [];
    var prefs = await SharedPreferences.getInstance();
    prefs.setStringList("alert", ip);
    prefs.setString("enable", _enabled.toString());
    // For Notifications
    var androidInitialize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    localNotifications = new FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);

    // Configure BackgroundFetch.
    try {
      var status = await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: 15,
            forceAlarmManager: false,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE,
          ),
          _onBackgroundFetch,
          _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });

      // Schedule a "one-shot" custom-task in 10000ms.
      // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
      // where device must be powered (and delay will be throttled by the OS).
      // BackgroundFetch.scheduleTask(TaskConfig(
      //     taskId: "com.transistorsoft.customtask",
      //     delay: 10000,
      //     periodic: false,
      //     forceAlarmManager: true,
      //     stopOnTerminate: false,
      //     enableHeadless: true));
    } catch (e) {
      print("[BackgroundFetch] configure ERROR: $e");
      setState(() {
        _status = e;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  // Show notification function
  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
      "channelId",
      "Local Notifcn",
      "This is Description",
      importance: Importance.max,
      enableVibration: true,
      // sound: RawResourceAndroidNotificationSound("sound"),
      priority: Priority.high,
      ongoing: true,
      styleInformation: BigTextStyleInformation(''),
    );

    var iosDetails = new IOSNotificationDetails();

    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotifications.show(
        0,
        "Slots Available at PIN Code : " + alert[0],
        "Vaccine : " +
            alert[1] +
            "\nDose No : " +
            alert[2] +
            "\nAge Group : " +
            alert[3] +
            " +",
        generalNotificationDetails);
  }

  Future fetchSlots(SharedPreferences prefs, String taskId, String vaccineType,
      String doseNo, String ageIp,
      {String pinCode = "000000"}) async {
    var time = DateTime.now();
    _events = [];
    String urlDate = time.day.toString() +
        "-" +
        time.month.toString() +
        "-" +
        time.year.toString();
    var fetchUrl =
        "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=" +
            pinCode +
            "&date=" +
            urlDate;
    var url = Uri.parse(fetchUrl);
    final response = await http.get(url);
    CalenderByPin data = CalenderByPin.fromJson(jsonDecode(response.body));
    var noOfHospitals;
    if (data.centers != null) {
      noOfHospitals = data.centers.length;
    } else {
      noOfHospitals = 0;
    }

    print(fetchUrl);
    print("#ofHosp:" + noOfHospitals.toString());
    // print(data.centers[0].sessions[0].availableCapacity);

    List<List<String>> details = [];

    for (var i = 0; i < noOfHospitals; i++) {
      var noOfSessions = data.centers[i].sessions.length;

      List<String> temp = [];
      temp.add(data.centers[i].name);
      temp.add("Address : " +
          data.centers[i].address.toLowerCase() +
          ", " +
          data.centers[i].stateName);
      temp.add("Fee type : " + data.centers[i].feeType);
// Structure : name,address,fee(with type),date,dose 1/2,vaccine type,age
      for (var j = 0; j < noOfSessions; j++) {
        if (doseNo == '1' &&
            data.centers[i].sessions[j].minAgeLimit.toString() == ageIp &&
            data.centers[i].sessions[j].availableCapacity > 0 &&
            data.centers[i].sessions[j].vaccine == vaccineType &&
            data.centers[i].sessions[j].availableCapacityDose1 > 0) {
          //show notifcn
          temp.add(data.centers[i].sessions[j].date);
          temp.add("Dose 1 Capacity : " +
              data.centers[i].sessions[j].availableCapacityDose1.toString());
          temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
          temp.add(
              "Age : " + data.centers[i].sessions[j].minAgeLimit.toString());
        } else if (doseNo == '2' &&
            data.centers[i].sessions[j].minAgeLimit.toString() == ageIp &&
            data.centers[i].sessions[j].availableCapacity > 0 &&
            data.centers[i].sessions[j].vaccine == vaccineType &&
            data.centers[i].sessions[j].availableCapacityDose2 > 0) {
          temp.add(data.centers[i].sessions[j].date);
          temp.add("Dose 2 Capacity: " +
              data.centers[i].sessions[j].availableCapacityDose2.toString());
          temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
          temp.add("Age Limit : " +
              data.centers[i].sessions[j].minAgeLimit.toString());
        }
        print(temp);
      }
      if (temp.isNotEmpty && temp.length > 3) {
        details.add(temp);

        // _showNotification();
        print(temp);
        // this.mounted = true;
        //TODO fix state
        if (this.mounted) {
          setState(() {
            _events.insert(0, temp);
          });
        } else {
          _events.insert(0, temp);
        }
        // _events.insert(0, temp);
        // setState(() {
        //   _events.insert(0, temp);
        //   // prefs.setStringList(i.toString(), temp);
        // });
      }

      // print("---------------------------------------------------");
    }
    if (details.isNotEmpty) {
      _showNotification();

      // onClickEnable(false);
    }
  }

  sec5Timer(SharedPreferences prefs, String taskId, String vaccineType,
      String doseNo, String ageIp,
      {String pinCode = "000000"}) {
    Timer.periodic(Duration(seconds: 240), (timer) {
      if (!_enabled) {
        timer.cancel();
      }
      print("5 sec timer");
      fetchSlots(prefs, taskId, alert[1], alert[2], alert[3],
          pinCode: alert[0]);
    });
  }

  void _onBackgroundFetch(String taskId) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // DateTime timestamp = new DateTime.now();
    //fetch slots in background
    // This is the fetch-event callback.
    SharedPreferences prefs;
    _events = [];
    print("[BackgroundFetch] Event received: $taskId");

    sec5Timer(prefs, taskId, alert[1], alert[2], alert[3], pinCode: alert[0]);
    // setState(() {
    //   _events.insert(0, "$taskId@${timestamp.toString()}");
    // });
    // Persist fetch events in SharedPreferences
    //
    // prefs.setString(EVENTS_KEY, jsonEncode(_events));

    // if (taskId == "flutter_background_fetch") {
    // Schedule a one-shot task when fetch event received (for testing).
    /*
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 5000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresNetworkConnectivity: true,
          requiresCharging: true
      ));
       */
    // }

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  void onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    initSetEnable(enabled);
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      // setState(() {
      //   _events = [];
      // });
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _onClickClear() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove(EVENTS_KEY);
    setState(() {
      _events = [];
    });
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vaccine Notifier",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () {
                _onClickClear();
                Navigator.pop(context, false);
              },
            ),
            title: const Text(
              'Available Slots',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 31, 96),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.amberAccent,
            brightness: Brightness.light,
            actions: <Widget>[
              Switch(value: _enabled, onChanged: onClickEnable),
            ]),
        //  (_events.isEmpty)
        // ? NotifyForm(_enabled, onClickEnable)
        // : Container(
        body: (_events.isEmpty)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("NO SLOTS AVAILABLE",
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 31, 96),
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.only(left: 9.0, top: 9.0, bottom: 9.0),
                        labelStyle:
                            TextStyle(color: Colors.blue, fontSize: 20.0),
                        // labelText: "[${event[0]}]"
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Alert created for PIN code: " + alert[0],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              " Vaccine Type: " + alert[1],
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              " Dose No. " + alert[2],
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          alert[3] == '0'
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "Age Group: 0 - 17 ",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "Age Group: " + alert[3] + "+",
                                    style: TextStyle(
                                        color: Colors.deepOrangeAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8),
                            child: Text(
                              "You will be noified whenever the slots are available.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, left: 8.0, right: 8),
                            child: Text(
                              "If you have received notifcation turn off Alert to see List of Hospitals if not visible",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                // height: 450,
                child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount: _events.length,
                    itemBuilder: (BuildContext context, int index) {
                      var event = _events;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputDecorator(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                  left: 9.0, top: 9.0, bottom: 9.0),
                              labelStyle:
                                  TextStyle(color: Colors.blue, fontSize: 20.0),
                              // labelText: "[${event[0]}]"
                            ),
                            child: Column(
                              children: [
                                // Text(
                                //   event[index].toString(),
                                //   style: TextStyle(
                                //       color: Colors.black, fontSize: 16.0),
                                // ),
                                Text(
                                  event[index][0]
                                      .toString()
                                      .toUpperCase(), //Hospital Name
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  event[index][1].toString(), //Address
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 17),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    event[index][2].toString(), //Free type
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 17),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    event[index][6].toString() +
                                        "+", //Age Limit
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 17),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    event[index][5].toString(), //Vaccine Type
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                        fontSize: 17),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    event[index][4].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 17),
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             WebViewLoad()));
                                    launchURL(
                                        "https://selfregistration.cowin.gov.in");
                                  },
                                  child: Text("Book Slot"),
                                )
                              ],
                            )),
                      );
                    }),
              ),

        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _onClickClear();
                          },
                          color: Color.fromARGB(255, 0, 31, 96),
                          child: Text(
                            "Go Back",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18),
                          )),
                      // RaisedButton(
                      //     onPressed: _onClickStatus,
                      //     child: Text('Status: $_status')),
                      RaisedButton(
                          onPressed: _onClickClear,
                          color: Color.fromARGB(255, 0, 31, 96),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18),
                          ))
                    ]))),
      ),
    );
  }
}

// class WebViewLoad extends StatelessWidget {
// //   WebViewLoadUI createState() => WebViewLoadUI();
// // }

// // class WebViewLoadUI extends State<WebViewLoad> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Vaccine Notifier",
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.amber,
//           automaticallyImplyLeading: true,
//           centerTitle: true,
//           title: Text(
//             'Book Slots',
//             style: TextStyle(
//               color: Color.fromARGB(255, 0, 31, 96),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         body: WebView(
//           initialUrl: 'https://selfregistration.cowin.gov.in',
//           javascriptMode: JavascriptMode.unrestricted,
//         ),
//       ),
//     );
//   }
// }

// class NotifyForm extends StatelessWidget {
//   final bool _enabled;
//   final Function onClickEnable;

//   NotifyForm(this._enabled, this.onClickEnable);

//   @override
//   Widget build(BuildContext context) {
//     // final _n1 = FocusNode();
//     // final _n2 = FocusNode();
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
//           child: TextFormField(
//             autofocus: false,
//             textInputAction: TextInputAction.next,
//             enableInteractiveSelection: false,
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).requestFocus(new FocusNode());
//             },
//             decoration: InputDecoration(
//                 labelText: 'PIN Code',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             maxLength: 6,
//             keyboardType: TextInputType.number,
//             style: TextStyle(fontSize: 20),
//             controller: myController1,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
//           child: TextFormField(
//             autofocus: false,
//             textInputAction: TextInputAction.next,
//             enableInteractiveSelection: false,
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).requestFocus(new FocusNode());
//             },
//             decoration: InputDecoration(
//                 labelText: 'Vaccine Type',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             // maxLength: 6,
//             // keyboardType: TextInputType.number,
//             style: TextStyle(fontSize: 20),
//             controller: myController2,
//             //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
//           child: TextFormField(
//             autofocus: false,
//             textInputAction: TextInputAction.next,
//             enableInteractiveSelection: false,
//             onFieldSubmitted: (_) {
//               FocusScope.of(context).requestFocus(new FocusNode());
//             },
//             decoration: InputDecoration(
//                 labelText: 'Dose No',
//                 labelStyle: null,
//                 // suffixText: "suffixText" ?? '',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.black, width: 2),
//                 ),
//                 hintText: '',
//                 floatingLabelBehavior: FloatingLabelBehavior.always),
//             maxLength: 6,
//             keyboardType: TextInputType.number,
//             style: TextStyle(fontSize: 20),
//             controller: myController3,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           ),
//         ),
//         // Padding(
//         //   padding: const EdgeInsets.all(8.0),
//         //   child: DropdownButtonFormField(
//         //     // focusNode: _n1,
//         //     decoration: InputDecoration(
//         //         labelText: 'Vaccine Type',
//         //         labelStyle: null,
//         //         // suffixText: "suffixText" ?? '',
//         //         border: OutlineInputBorder(
//         //           borderSide: BorderSide(color: Colors.black, width: 2),
//         //         ),
//         //         hintText: '',
//         //         floatingLabelBehavior: FloatingLabelBehavior.always),
//         //     items: ["COVISHIELD", "COVAXIN", "SPUTNIK V"]
//         //         .map((label) => DropdownMenuItem(
//         //               child: Text(label.toString()),
//         //               value: label,
//         //             ))
//         //         .toList(),
//         //     onChanged: (value) {
//         //       vaccineIp = value;
//         //       FocusScope.of(context).requestFocus(new FocusNode());
//         //       print(vaccineIp);
//         //     },
//         //   ),
//         // ),
// Padding(
//   padding: const EdgeInsets.all(8.0),
//   child: DropdownButtonFormField(
//     // focusNode: _n2,
//     decoration: InputDecoration(
//         labelText: 'Dose No.',
//         labelStyle: null,
//         // suffixText: "suffixText" ?? '',
//         border: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.black, width: 2),
//         ),
//         hintText: '',
//         floatingLabelBehavior: FloatingLabelBehavior.always),
//     items: ["1", "2"]
//         .map((label) => DropdownMenuItem(
//               child: Text(label.toString()),
//               value: label,
//             ))
//         .toList(),
//     onChanged: (value) {
//       FocusScope.of(context).requestFocus(new FocusNode());
//       doseIp = value;

//       print(doseIp.toString());
//     },
//   ),
// ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SwitchListTile(
//             // activeTrackColor: Colors.blueAccent,
//             tileColor: Colors.amberAccent,
//             title: const Text(
//               'Create Alert',
//               style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold),
//             ),
//             value: _enabled,
//             onChanged: (value) {
//               if (myController1.text != null &&
//                   myController2.text != null &&
//                   myController3.text != null) {
//                 alert[0] = myController1.text;
//                 alert[1] = myController2.text;
//                 alert[2] = myController3.text;
//               }
//               onClickEnable(value);
//             },
//             secondary: const Icon(Icons.assignment_turned_in_outlined),
//           ),
//         ),
//         Text(
//           alert.toString(),
//         ),
//       ],
//     );
//   }
// }
