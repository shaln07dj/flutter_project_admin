import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<List<Map<String, dynamic>>> searchAppNumberAdmin(
    String searchValue, String token) async {
  String token_ = token;

  try {
    var requestBody = {
      "query":
          "SELECT application_records.application_id, application_records.user_id, application_records.first_name AS user_first_name, application_records.last_name AS user_last_name, application_records.email, application_records.assigned_admin_id, application_records.application_status, application_records.last_login, admin_records.first_name, admin_records.last_name, application_records.skyflow_id FROM application_records LEFT JOIN admin_records ON application_records.assigned_admin_id = admin_records.user_id WHERE (application_records.application_id LIKE '$searchValue%' AND application_records.assigned_admin_id IS NULL) OR (application_records.application_id LIKE '$searchValue%' AND application_records.assigned_admin_id IS NOT NULL)"
    };

    var c = jsonEncode(requestBody);
    Response response = await makeNetworkRequest("POST", token_, skyFlowBaseUrl,
        subUrl: sfSubUrl, vaultId: vaultId, endpoint: queryEndpoint, body: c);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = (response.data);

      List<dynamic> records = responseBody['records'];

      List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(records);

      return result;
    } else {
      return [];
    }
  } catch (error) {
    print('Error: $error');
    return [];
  }
}
