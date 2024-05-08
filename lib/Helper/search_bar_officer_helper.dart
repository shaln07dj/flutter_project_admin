import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<List<Map<String, dynamic>>> searchAppNumberOfficer(
    String searchValue, String token) async {
  String token_ = token;

  try {
    var requestBody = {
      "query":
          "SELECT * FROM $applicationRecordsTable WHERE application_id LIKE '$searchValue%'"
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
