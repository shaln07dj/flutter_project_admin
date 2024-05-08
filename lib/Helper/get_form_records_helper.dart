import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

getFormRecords(String token, userApplicationId) async {

  var skyFlowToken = await getSkyFlowToken() ?? '';

  var requestBody = {
    "query":
        "SELECT * FROM $formRecordsTable WHERE application_id = '$userApplicationId' ",
  };
  var encodedBody = jsonEncode(requestBody);

  Response resp = await makeNetworkRequest("POST", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      endpoint: queryEndpoint,
      body: encodedBody);

  if (resp.statusCode == 200) {
    var records = (resp.data)["records"];
    return records;
  } else {
    // Request failed
    return null;
  }
}
