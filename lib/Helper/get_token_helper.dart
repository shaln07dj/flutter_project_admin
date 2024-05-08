import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/redux/store.dart';

getToken(String token) async {
  String tokenUrl = 'https://$baseUrl$subUrl/$tokenEndPoint';

  Response response = await makeNetworkRequest("GETTOKEN", token, tokenUrl);

  if (response.statusCode == 200) {
    String skyFlowToken = response.data['token'];
    String role = response.data['role'];
    setRole(role);
    saveSkyFowToken(skyFlowToken);

    store.dispatch(UpdateAuthSkyFLowAction(skyFlowToken: skyFlowToken));
    return response;
  } else {

    debugPrint('Request failed with status: ${response.statusCode}.');
    return response;
  }
}
