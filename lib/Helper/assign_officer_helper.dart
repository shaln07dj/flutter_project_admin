import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';
import 'package:flutter/material.dart';

Future assignOfficer(String? assignAdminID, String? skyflowId) async {
  var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  var createdAt = timeStampResponse.data["created_at"];
  var updatedAt = timeStampResponse.data["updated_at"];
  debugPrint(
      "timeStampResponse inside assign_officer_helper created_at updated_at: $createdAt $updatedAt");

  var body = {
    "record": {
      "fields": {"assigned_admin_id": assignAdminID, "updated_at": updatedAt}
    },
    "tokenization": false
  };
  var encodedBody = jsonEncode(body, toEncodable: (value) {
    if (value == null) {
      return 'null';
    } else {
      return value;
    }
  });

  String token = await getSkyFlowToken() ?? '';
  print('Assigned Officer SkyflowId $skyflowId');

  Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      skyflowId: skyflowId,
      body: encodedBody);

  if (response.statusCode == 200) {
    // Post created successfully
    print('ASSIGNED OFFICER $response');
    return true;
  } else {
    // add logic when the request is failed.
  }
}
