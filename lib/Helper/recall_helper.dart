import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

void recallDocument(skyflowId) async {
  String recallUrl = 'https://$baseUrl$subUrl/$docRecall?skyflowId=$skyflowId';
  var skyFlowToken = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest("GET", skyFlowToken, recallUrl);

  if (response.statusCode == 200) {
    print('Document recalled succesfully');
  } else {
    throw Exception('Failed to recall document');
  }
}
