import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

checkOfficer(String firebaseToken) async {

  final Map<String, dynamic> params = {
    'redaction': 'PLAIN_TEXT',
    'fields': ['role', 'status'],
    'tokenization': 'false',
  };

  String skyflowToken = await getSkyFlowToken() ?? '';
  Response response = await makeNetworkRequest(
      "GET", skyflowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: adminRecordsTable,
      queryparams: params);

  if (response.statusCode == 200) {
    return response.data['records'][0]['fields'];
  } else {
    // Handle the error
    throw Exception('Failed to admin_view_helper');
  }
}

