import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<String?> getFormUrl(String skyflowId) async {
  debugPrint("tablename inside fetchSkyflowId $skyflowId");
  var skyFlowToken = await getSkyFlowToken() ?? '';
  final Map<String, dynamic> params = {
    'downloadURL': 'true',
  };

  String url =
      'https://a370a9658141.vault.skyflowapis-preview.com/v1/vaults/eea5b2820c82450eac8637ef32f8ca7a/configuration_records/$skyflowId?fields=file&downloadURL=true';

  // 'https://$skyFlowBaseUrl$sfSubUrl/$vaultId/configuration_records/$skyflowId?downloadURL=true&fields=file';

  try {
    Response response = await makeNetworkRequest("GET", skyFlowToken, url);

    if (response.statusCode == 200) {
      var records = response.data;

      var fileUrl = records['fields']['file'];
      debugPrint("file url is here $fileUrl");

      return fileUrl;
    } else if (response.statusCode == 404) {
      // Handle 404 response
    } else {
      var res = 'Request failed with status: ${response.statusCode}.';
      return res;
    }
  } catch (e) {
    // Handle Dio errors
    print('Error: $e');
    return null;
  }
  return null;
}
