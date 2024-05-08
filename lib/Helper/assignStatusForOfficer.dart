import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';
import 'package:flutter/material.dart';

Future assignStatusForOfficer(String? status, String? skyflowId) async {
  var body = {
    "record": {
      "fields": {"status": status}
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
  print('assignStatusForOfficer SkyflowId $skyflowId');

  Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: adminRecordsTable,
      skyflowId: skyflowId,
      body: encodedBody);

  if (response.statusCode == 200) {
    // Post created successfully
    print('assignStatusForOfficer $response');
    return true;
  } else {
    // add logic when the request is failed.
  }
}
