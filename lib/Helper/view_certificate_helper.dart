import 'dart:typed_data';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<Uint8List> viewCertificate(String skyflowId) async {
  String url = 'https://$baseUrl$subUrl/$viewCert?skyflowId=$skyflowId';
  var skyFlowToken = await getSkyFlowToken() ?? '';

  dynamic response = await makeNetworkRequest("GET_FILE", skyFlowToken, url);

  if (response.statusCode == 200) {
    return Uint8List.fromList(response.data); // Return the certificate content
  } else {
    throw Exception('Failed to load Certificate');
  }
}
