import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/update_app_status_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

getRecords(String token, offSetVAlue, handleLoading) async {
  var skyFlowToken = await getSkyFlowToken() ?? '';
  const registration = "Registration";

  final Map<String, String> params = {
    'redaction': 'PLAIN_TEXT',
    'tokenization': 'false',
    'offset': offSetVAlue.toString(),
    'limit': '25',
    'downloadURL': 'false',
    'order_by': 'NONE'
  };

  Response resp = await makeNetworkRequest("GET", skyFlowToken, skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: applicationRecordsTable,
      queryparams: params);

  if (resp.statusCode == 200) {
    var records = (resp.data)['records'];

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
  } else if (resp.statusCode == 404) {
    handleLoading('failed');
    return [];
  } else {
    var res = 'Request failed with status: ${resp.statusCode}.';
    // Request failed
    handleLoading('failed');
    return res;
  }
}
