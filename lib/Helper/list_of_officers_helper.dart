import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

listOfOfficers(String token, handleLoading) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';

  final Map<String, dynamic> params = {
    'fields': [
      'skyflow_id',
      'user_id',
      'first_name',
      'last_name',
      'email',
      'last_login',
      'role',
      'status'
    ],
    'tokenization': 'false',
  };

  Response resp = await makeNetworkRequest("GET", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: adminRecordsTable,
      queryparams: params);

  // resp.statusCode = 404;
  if (resp.statusCode == 200) {
    debugPrint('list of officers Pauzible');
    // Parse the response JSON
    var responseData = (resp.data)['records'];
    debugPrint('Response Officer$responseData');

    if (responseData is List) {
      handleLoading('success');
    }
    if (responseData.isEmpty) {
      handleLoading('failed');
    }

    return responseData;
  } else if (resp.statusCode == 404) {
    handleLoading('failed');
    return [];
  } else {
    // Handle the error, e.g., by throwing an exception or returning an empty list
    throw Exception('Failed to load officers');
  }
}
