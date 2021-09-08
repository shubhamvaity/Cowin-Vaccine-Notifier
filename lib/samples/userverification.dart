import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

String token;
void main() {
  int mobileNO = 8850076235;
  getOTP(mobileNO);
  // print(traxDetails);
}

// String url1 = "https://cdn-api.co-vin.in/api/v2/auth/public/generateOTP";
String genMob = "https://cdn-api.co-vin.in/api/v2/auth/generateMobileOTP";
String valMob = "https://cdn-api.co-vin.in/api/v2/auth/validateMobileOtp";
dynamic getOTP(int mobNo) async {
  var url = Uri.parse(genMob);
  var body = json.encode({
    "mobile": mobNo,
    "secret":
        "U2FsdGVkX188MP4w5NyFOfUN6GIJNCw9CGhoALzcL41VAsHMKSGn0nhMJz2IqFUWonMLlnLeuMvXstrM7hlprw==",
  });
  final response = await http.post(
    url,
    // Send authorization headers to the backend.
    headers: {"accept": "application/json", "Content-Type": "application/json"},
    body: body,
  );
  if (response.statusCode == 200) {
    var responseJson = jsonDecode(response.body);
    print(responseJson["txnId"]);
    String traxId = responseJson["txnId"].toString();
    String name = stdin.readLineSync();
    print(name);

    var bytes = utf8.encode(name.toString()); // data being hashed

    var digest = sha256.convert(bytes);

    // print("Digest as bytes: ${digest.bytes}");
    print("Digest as hex string: $digest");
    print(digest.toString().length);

    var url2 = Uri.parse(valMob);
    var body2 = json.encode({"otp": digest.toString(), "txnId": traxId});
    print(body2);
    final response2 = await http.post(url2,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json"
        },
        body: body2);
    var responseJson2 = jsonDecode(response2.body);
    token = "Bearer " + responseJson2["token"].toString();
    print(responseJson2["token"]);
  } else if (response.statusCode == 400) {
    print(response.body);
  }

  var benReq =
      Uri.parse("https://cdn-api.co-vin.in/api/v2/appointment/beneficiaries");
  final benResponse = await http.get(
    benReq,
    headers: {
      "accept": "application/json",
      "authorization": token,
    },
  );
  print(benResponse.statusCode);
  print(benResponse.headers);

  var benjson = jsonDecode(benResponse.body);
  print(benjson.toString());
// "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxx"
}
