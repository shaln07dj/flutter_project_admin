import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/admin_view.dart';

Future updateSkyflowDisplayName(String firstName, String lastName,
    {required Function(bool status) handleUpdating}) async {
  // var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  // dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  // var created_at = timeStampResponse.data["created_at"];
  // var updated_at = timeStampResponse.data["updated_at"];
  // debugPrint(
  //     "timeStampResponse inside update_displayname_helper created_at updated_at: $created_at $updated_at");

  debugPrint("Inside updateSkyflowDisplayName");
  var body = {
    "firstName": firstName,
    "lastName": lastName,
    // "updated_at": updated_at
  };
  var encodedBody = jsonEncode(body);

  User? user = FirebaseAuth.instance.currentUser;

  String? firebaseToken = await user?.getIdToken() ?? '';
  saveFireBaseToken(firebaseToken);
  // String updateNameUrl = 'https://$baseUrl$subUrl/$updateName';

  Response response = await makeNetworkRequest(
    "POST",
    firebaseToken,
    baseUrl,
    subUrl: subUrl,
    body: encodedBody,
    endpoint: updateName,
  );

  if (response.statusCode == 200) {
    await user?.updateDisplayName('$firstName $lastName');
    handleUpdating(true);
    await navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => admin_view(
          route: true,
        ),
      ),
      (route) => false,
    );
    return true;
  } else {
    handleUpdating(false);
  }
}
