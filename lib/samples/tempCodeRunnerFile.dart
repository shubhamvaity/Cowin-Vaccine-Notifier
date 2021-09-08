 // String traxId = responseJson["txnId"].toString();
    // String name = stdin.readLineSync();
    // print(name);

    // var bytes = utf8.encode(name.toString()); // data being hashed

    // var digest = sha256.convert(bytes);

    // // print("Digest as bytes: ${digest.bytes}");
    // print("Digest as hex string: $digest");
    // print(digest.toString().length);

    // var url2 =
    //     Uri.parse("https://cdn-api.co-vin.in/api/v2/auth/public/confirmOTP");
    // var body2 = json.encode({"otp": digest.toString(), "txnId": traxId});
    // print(body2);
    // final response2 = await http.post(url2,
    //     headers: {
    //       "accept": "application/json",
    //       "Content-Type": "application/json"
    //     },
    //     body: body2);
    // var responseJson2 = jsonDecode(response2.body);
    // token = "Bearer " + responseJson2["token"].toString();
    // print(responseJson2["token"]);