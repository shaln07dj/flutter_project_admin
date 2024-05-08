import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future updateSingleStatus(String applicantStatus, String skyflowId,
    Function(String status) setApplicationStatus) async {
  String updateStatusUrl =
      'https://$skyFlowBaseUrl$sfSubUrl/$vaultId/$applicationRecordsTable/$skyflowId';
  String token = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest("GET", token, updateStatusUrl);

  if (response.statusCode == 200) {
    setApplicationStatus((response.data)['fields']['application_status']);
    return true;
  } else {
    print(
        'Failed to update Single Status. Status Code: ${response.statusCode}');
  }
}
