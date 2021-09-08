import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final myController2 = TextEditingController();
String vaccineIp = "", doseIp = "", ageIp = "";
List<String> ipList = ["", "", "", ""];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myController1 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('Title'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: Form(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
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
                          hintText: '',
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
                      // focusNode: _n1,
                      decoration: InputDecoration(
                          labelText: 'Vaccine Type',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: '',
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
                      // focusNode: _n2,
                      decoration: InputDecoration(
                          labelText: 'Dose No.',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: '',
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
                      // focusNode: _n2,
                      decoration: InputDecoration(
                          labelText: 'Age Group',
                          labelStyle: null,
                          // suffixText: "suffixText" ?? '',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          hintText: '',
                          floatingLabelBehavior: FloatingLabelBehavior.always),
                      items: ["0 - 17", "18 - 44", "45+"]
                          .map((label) => DropdownMenuItem(
                                child: Text(label.toString()),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (value.toString() == "0 - 17") {
                          ageIp = "0";
                        } else if (value.toString() == "18 - 44") {
                          ageIp = "18";
                        } else if (value.toString() == "45+") {
                          ageIp = "45";
                        }

                        print(ageIp.toString());
                      },
                    ),
                  ),
                  RaisedButton(
                      onPressed: () async {
                        ipList[0] = (myController1.text);
                        ipList[1] = (vaccineIp);
                        ipList[2] = (doseIp);
                        ipList[3] = (ageIp);
                        var pf1 = await SharedPreferences.getInstance();
                        pf1.setStringList("ipList", ipList);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => MyBgApp(ipList),
                        //   ),
                        // );
                      },
                      // onPressed: () {
                      //   //right way: use context in below level tree with MaterialApp
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => MyBgApp(),
                      //     ),
                      //   );
                      // },
                      child: const Text('SCAN')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
