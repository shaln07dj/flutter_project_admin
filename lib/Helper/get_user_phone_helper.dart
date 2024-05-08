import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future getUserPhone(String userId) async {
  try {
    var requestBody = {
      "query":
          "SELECT phone_number FROM $userRecordsTable WHERE user_id = '$userId' "
    };

    var skyFlowToken = await getSkyFlowToken() ?? '';
    var encodedBody = jsonEncode(requestBody);

    Response response = await makeNetworkRequest(
        "POST", skyFlowToken, skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        endpoint: queryEndpoint,
        body: encodedBody);

    if (response.statusCode == 200) {
      var records = response.data['records'];
      var userPhone = records[0]['fields']['phone_number'];
      // debugPrint('userPhone successfully fetched: $userPhone');
      // ignore: unnecessary_null_comparison
      return userPhone != null ? userPhone : "";
    }
  } catch (error) {
    debugPrint('Error getting user phone no: $error');
    return null;
  }
}
