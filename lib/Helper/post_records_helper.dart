import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future getRecords(
  Function(String status) handleLoading,
  applicatonId,
  int offSetValue,
) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';

  var requestBody = {
    "query":
        "SELECT category, sub_category, status, skyflow_id, created_at, updated_at, description FROM $signRecordsTable WHERE application_id= '$applicatonId' LIMIT 25 OFFSET ${offSetValue.toString()}",
  };

  var encodeBody = jsonEncode(requestBody);
  final Map<String, dynamic> params = {'redaction': 'PLAIN_TEXT'};

  Response response = await makeNetworkRequest(
      "POST", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      endpoint: queryEndpoint,
      queryparams: params,
      body: encodeBody);

  if (response.statusCode == 200) {
    var records = (response.data)['records'];
    // debugPrint('Records in getRecords::  $records');
    handleLoading('success');
    return records;
  } else if (response.statusCode == 404) {
    handleLoading('failed');
    return [];
  } else {
    debugPrint('Request failed with status: ${response.statusCode}');
  }
}
