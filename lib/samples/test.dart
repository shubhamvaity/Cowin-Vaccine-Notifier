import '../models/CalenderByPin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  var time = DateTime.now();
  var pinCode = "000000";
  var vaccineType = "COVISHIELD";
  var doseNo = 2;
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
  var noOfHospitals = data.centers.length;
  print(fetchUrl);
  print("#ofHosp:" + noOfHospitals.toString());
  // print(data.centers[0].sessions[0].availableCapacity);

  List details = [];

  for (var i = 0; i < noOfHospitals; i++) {
    var noOfSessions = data.centers[i].sessions.length;

    List temp = [];
    temp.add(data.centers[i].name);
    temp.add(data.centers[i].address + ", " + data.centers[i].stateName);
    temp.add(data.centers[i].feeType);
// Structure : name,address,fee(with type),date,dose 1/2,vaccine type,age
    for (var j = 0; j < noOfSessions; j++) {
      if (doseNo == 1 &&
          data.centers[i].sessions[j].availableCapacity > 0 &&
          data.centers[i].sessions[j].vaccine == vaccineType &&
          data.centers[i].sessions[j].availableCapacityDose1 > 0) {
        //show notifcn
        temp.add(data.centers[i].sessions[j].date);
        temp.add("DOSE 1 : " +
            data.centers[i].sessions[j].availableCapacityDose1.toString());
        temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
        temp.add("Age : " + data.centers[i].sessions[j].minAgeLimit.toString());
      } else if (doseNo == 2 &&
          data.centers[i].sessions[j].availableCapacity > 0 &&
          data.centers[i].sessions[j].vaccine == vaccineType &&
          data.centers[i].sessions[j].availableCapacityDose2 > 0) {
        temp.add(data.centers[i].sessions[j].date);
        temp.add("DOSE 2 : " +
            data.centers[i].sessions[j].availableCapacityDose2.toString());
        temp.add("Vaccine : " + data.centers[i].sessions[j].vaccine);
        temp.add("Age : " + data.centers[i].sessions[j].minAgeLimit.toString());
      }
    }
    if (temp.isNotEmpty && temp.length > 3) {
      details.add(temp);
      print(temp);
    }

    // print("---------------------------------------------------");
  }
  // print(details);
}
