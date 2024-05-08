import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

postRecord(
  String? applicationId,
  Function(String status) handleLoading,
  int offSetValue,
) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';

  var requestBody = {
    "query":
        "SELECT skyflow_id, category, sub_category, description, file, application_id, user_id, updated_at FROM $fileRecordsTable WHERE application_id = '$applicationId' LIMIT 25 OFFSET ${offSetValue.toString()}", // ${'application_no'}
  };

  var encodedBody = jsonEncode(requestBody);

  final Map<String, dynamic> params = {'redaction': 'PLAIN_TEXT'};

  Response response = await makeNetworkRequest(
      "POST", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      endpoint: queryEndpoint,
      queryparams: params,
      body: encodedBody);

  if (response.statusCode == 200) {
    var records = response.data['records'];
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
