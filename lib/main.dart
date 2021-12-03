import './backgroundFetchNotify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';

// adb shell cmd jobscheduler run -f com.shubhamvaity.vaccinenotifier 999
List<String> createdAlerts = [];
String enableVal;
void main() {
  // Enable integration testing with the Flutter Driver extension.
  // See https://flutter.io/testing/ for more info.
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Vaccine Notifier",
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      // home: MyBgApp(["400004", "COVISHIELD", "2"]),
    );
  }
}

final myController1 = TextEditingController();
final myController2 = TextEditingController();
String vaccineIp = "", doseIp = "", ageIp = "", feeType = "";
List<String> ipList = ["", "", "", "", ""];

class HomeScreen extends StatefulWidget {
  // const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initPS();
  }

  Future<void> initPS() async {
    var pf2 = await SharedPreferences.getInstance();
    setState(() {
      createdAlerts = pf2.getStringList('alert');
      enableVal = pf2.getString("enable");
    });
  }

  @override
  Widget build(BuildContext context) {
    initPS();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Vaccine Notifier',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 31, 96),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: Form(
              autovalidate: true,
              key: _formKey,
              child: Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Card(
                  //     child: Column(
                  //       children: [],
                  //     ),
                  //   ),
                  // ),
                  (createdAlerts != null && enableVal == 'true')
                      ? (createdAlerts[3] == '0'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.only(
                                      left: 9.0, top: 9.0, bottom: 9.0),
                                  labelStyle: TextStyle(
                                      color: Colors.blue, fontSize: 20.0),
                                  // labelText: "[${event[0]}]"
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Alert created for PIN code: " +
                                          createdAlerts[0],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " Vaccine Type: " + createdAlerts[1],
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " Dose No. " + createdAlerts[2],
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Age Group: 0 - 17 ",
                                      style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Re-Enter Details to modify the alert.")
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.only(
                                      left: 9.0, top: 9.0, bottom: 9.0),
                                  labelStyle: TextStyle(
                                      color: Colors.blue, fontSize: 20.0),
                                  // labelText: "[${event[0]}]"
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Alert created for PIN code: " +
                                          createdAlerts[0],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " Vaccine Type: " + createdAlerts[1],
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      " Dose No.: " + createdAlerts[2],
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Age Group: " + createdAlerts[3] + "+",
                                      style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Re-Enter Details to modify the alert.")
                                  ],
                                ),
                              ),
                            ))
                      : Padding(
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
                                Text(
                                  "NO ALERT CREATED",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 31, 96),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("Enter Details to create the alert.")
                              ],
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 6) {
                          return 'Please enter valid PIN code';
                        }
                        return null;
                      },
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      enableInteractiveSelection: false,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      decoration: InputDecoration(
                          labelText: 'PIN Code',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: 'Enter PIN Code',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black26,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 20),
                      controller: myController1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose Vaccine Type';
                        }
                        return null;
                      },
                      // focusNode: _n1,
                      decoration: InputDecoration(
                          labelText: 'Vaccine Type',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: 'Choose Vaccine type',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black26,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      items: ["COVISHIELD", "COVAXIN", "SPUTNIK V"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label.toString()),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        vaccineIp = value;
                        FocusScope.of(context).requestFocus(new FocusNode());
                        print(vaccineIp);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose Dose Number';
                        }
                        return null;
                      },
                      // focusNode: _n2,
                      decoration: InputDecoration(
                          labelText: 'Dose No.',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: 'Choose Dose no.',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black26,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      items: ["1", "2"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label.toString()),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        doseIp = value;

                        print(doseIp.toString());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose appropriate Age Group';
                        }
                        return null;
                      },
                      // focusNode: _n2,
                      decoration: InputDecoration(
                          labelText: 'Age Group',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: 'Choose Age group',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black26,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      items: ["18 & Above", "18-44 Only", "45 & Above"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label.toString()),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (value.toString() == "18 & Above") {
                          ageIp = "18";
                        } else if (value.toString() == "18 - 44") {
                          ageIp = "18";
                        } else if (value.toString() == "45+") {
                          ageIp = "45";
                        }

                        print(ageIp.toString());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose Fee Type';
                        }
                        return null;
                      },
                      // focusNode: _n2,
                      decoration: InputDecoration(
                          labelText: 'Fee Type',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: 'Choose Fee Type',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black26,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      items: ["Free", "Paid"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label.toString()),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (value.toString() == "Free") {
                          feeType = "Free";
                        } else if (value.toString() == "Paid") {
                          feeType = "Paid";
                        }

                        print(feeType.toString());
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 0, 31, 96)),
                    ),
                    onPressed: () async {
                      ipList[0] = (myController1.text);
                      ipList[1] = (vaccineIp);
                      ipList[2] = (doseIp);
                      ipList[3] = (ageIp);
                      ipList[4] = (feeType);
                      print(ipList);
                      var pf1 = await SharedPreferences.getInstance();
                      pf1.setStringList("ipList", ipList);
                      if (_formKey.currentState.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyBgApp(ipList),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'CREATE ALERT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18),
                    ),
                    // color: Color.fromARGB(255, 0, 31, 96),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
