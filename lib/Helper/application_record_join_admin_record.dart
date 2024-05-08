import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/update_app_status_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

applicationRecordJoinAdmin(String token, handleLoading) async {
  const registration = "Registration";

  var skyFlowToken = await getSkyFlowToken() ?? '';

  var requestBody = {
    "query":
        "SELECT application_records.application_id, application_records.user_id, application_records.first_name AS user_first_name, application_records.last_name AS user_last_name,application_records.email, application_records.assigned_admin_id, application_records.application_status, application_records.last_login, admin_records.first_name, admin_records.last_name,  application_records.skyflow_id FROM application_records LEFT JOIN admin_records ON application_records.assigned_admin_id = admin_records.user_id WHERE application_records.assigned_admin_id IS NULL OR admin_records.user_id IS NOT NULL"
  };
  var encodedBody = jsonEncode(requestBody);

  Response response = await makeNetworkRequest(
      "POST", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      endpoint: queryEndpoint,
      body: encodedBody);

  // response.statusCode = 404;
  if (response.statusCode == 200) {
    var records = (response.data)['records'];

    for (var record in records) {
      Map<String, dynamic> fields = record['fields'];
      if (fields.containsKey('application_status') == false) {
        var skyflowId = fields['skyflow_id'];
        fields['application_status'] = registration;
        updateAppStatus(registration, skyflowId, (status) => null);
      }
    }

    if (records is List) {
      handleLoading('success');
    }
    if (records.isEmpty) {
      handleLoading('failed');
    }

    savegetApplictionRecordsList('applicationRecordList', records);
    return records;
  } else if (response.statusCode == 404) {
    handleLoading('failed');
    return [];
  } else {
    var res = 'Request failed with status: ${response.statusCode}.';
    handleLoading('failed');
    return res;
  }
}
