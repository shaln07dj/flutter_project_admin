import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'dart:convert';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future sendEmailSMS(String firebaseToken, String userAction, String userEmail,
    String skyflowId, String userPhone) async {
  var requestBody = {
    "userAction": userAction,
    "skyflow_id": skyflowId,
    "userEmail": userEmail,
    "userMobile": userPhone
  };

  var encodedBody = jsonEncode(requestBody);
  Response response = await makeNetworkRequest("POST", firebaseToken, baseUrl,
      subUrl: subUrl, endpoint: emailSmsEndpoint, body: encodedBody);

  if (response.statusCode == 200) {
    // debugPrint(
    //     "Email & SMS sent successfully for userAction $userAction $skyflowId $userEmail");
    return true;
  } else {
    // debugPrint(
    //     "Email & SMS sent failed for userAction $userAction $skyflowId $userEmail");
    return false;
  }
}
