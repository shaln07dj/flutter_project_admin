import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

fetchSkyflowId(String token, String tableName, bool? setDisplayname,
    {String? firstName, String? lastName}) async {
  debugPrint("tablename inside fetchSkyflowId $tableName");
  var skyFlowToken = await getSkyFlowToken() ?? '';
  final Map<String, dynamic> params = {
    'redaction': 'PLAIN_TEXT',
    'fields': [
      'skyflow_id',
    ],
    'tokenization': 'false',
    'limit': '25',
    'downloadURL': 'false',
    'order_by': 'NONE'
  };

  Response response = await makeNetworkRequest(
      "GET", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: tableName,
      queryparams: params);

  if (response.statusCode == 200) {
    var records = response.data['records'];

    if (records is List) {
      var skyflowId = records[0]['fields']['skyflow_id'];
      debugPrint("Skyfow Id is here $skyflowId");

      return skyflowId;
    }
  } else if (response.statusCode == 404) {
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    return res;
  }
}
