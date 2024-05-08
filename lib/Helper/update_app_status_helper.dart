import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/update_single_status_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future updateAppStatus(String applicantStatus, String skyflowId,
    Function(String status) setApplicationStatus) async {
  var body = {
    "record": {
      "fields": {
        "application_status": applicantStatus,
      }
    },
    "tokenization": false
  };
  var encodeBody = jsonEncode(body);
  String token = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest("PUT", token, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      skyflowId: skyflowId,
      body: encodeBody);

  if (response.statusCode == 200) {
    updateSingleStatus(applicantStatus, skyflowId, setApplicationStatus);

    return true;
  } else {
    print('Failed to Update app status. Status Code: ${response.statusCode}');
  }
}
