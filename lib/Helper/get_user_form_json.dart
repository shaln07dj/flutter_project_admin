import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future getUserFormJson(String firebaseToken, String skyflowId) async {
  try {
    debugPrint("Inside getUserFormJson");
    debugPrint("firebaseToken Inside getUserFormJson: $firebaseToken");

    var body = {
      "skyflow_id": skyflowId,
    };
    var encodedBody = jsonEncode(body);
    debugPrint("encodedBody Inside getUserFormJson: $encodedBody");

    String url = 'https://$baseUrl$subUrl/$jsonForm';
    debugPrint("url Inside getUserFormJson: $url");

    Response resp = await makeNetworkRequest(
      "POST",
      firebaseToken,
      baseUrl,
      subUrl: subUrl,
      endpoint: jsonForm,
      body: encodedBody,
    );

    debugPrint("resp statuscode: ${resp.statusCode}");

    if (resp.statusCode == 200 && resp.data['data'] != null) {
      debugPrint("Inside try if getUserFormJson: ${resp.data['data']}");
      return resp.data['data']; //value of data key
    }
  } catch (error) {
    debugPrint("Catch getUserFormJson : $error");
    return error; // this should be null
  }
}
