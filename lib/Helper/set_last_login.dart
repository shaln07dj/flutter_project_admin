import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/get_skyflow_id.dart';
import 'dart:convert';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future setLastLogin() async {
  try {
    var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
    dynamic timeStampResponse =
        await makeNetworkRequest("GET", "", timeStampUrl);
    var createdAt = timeStampResponse.data["created_at"];
    var updatedAt = timeStampResponse.data["updated_at"];
    debugPrint(
        "timeStampResponse inside set_last_login created_at updated_at: $createdAt $updatedAt");

    var body = {
      "record": {
        "fields": {"last_login": createdAt}
      },
      "tokenization": false
    };
    var encodedBody = jsonEncode(body);
    String token = await getSkyFlowToken() ?? '';
    debugPrint("Skyflow token inside set_last_login: $token");

    var skyflowId = await fetchSkyflowId(token, adminRecordsTable, false);

    debugPrint("Skyflow id inside set_last_login: $skyflowId");

    Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
        subUrl: sfSubUrl,
        vaultId: vaultId,
        tableName: adminRecordsTable,
        queryString: skyflowId,
        body: encodedBody);
    debugPrint("Response of PUT set last login: $response");

    if (response.statusCode == 200) {
      debugPrint("last login added in admin_records successfully");
    } else {
      debugPrint("last login added in admin_records unsuccessful: $response");
    }
  } catch (error) {
    debugPrint("Error in setLastLogin: $error");
  }
}
