import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/file_upload_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future sendFileInfo(
    category,
    subCategory,
    description,
    bool isDeleted,
    userApplicationId,
    userId,
    adminUserId,
    String filename,
    String bytes,
    String? blobUrl,
    Function callback,
    Function isSuccessfull,
    Function resetFileInfo,
    Function(String message) showToast,
    String requestname,
    String recipientEmail,
    String recipientName,
    Function(bool status) resetCategory,
    Function(bool status) resetSubCategory,
    Function resetTextField,
    Function(bool status) fileReset,
    Function resetDropZone,
    Function resetSubCategoryDefault) async {
  var timeStampUrl = "https://$baseUrl$subUrl/$getTimeStamp";
  dynamic timeStampResponse = await makeNetworkRequest("GET", "", timeStampUrl);
  var created_at = timeStampResponse.data["created_at"];
  var updated_at = timeStampResponse.data["updated_at"];
  debugPrint(
      "timeStampResponse inside send_file_info_helper created_at updated_at: $created_at $updated_at");

  var b = {
    "records": [
      {
        "fields": {
          'category': category,
          'sub_category': subCategory,
          'description': description,
          "is_deleted": isDeleted,
          'application_id': userApplicationId,
          "status": "TOBESIGNED",
          "uploaded_by": adminUserId,
          "uploaded_for": userId,
          "user_id": adminUserId,
          "created_at": created_at,
          "updated_at": updated_at
        }
      }
    ],
    "tokenization": false
  };
  var encodedBody = jsonEncode(b);
  String token = await getSkyFlowToken() ?? '';
  Response response = await makeNetworkRequest(
    "POST",
    token,
    skyFlowBaseUrl,
    subUrl: sfSubUrl,
    vaultId: vaultId,
    endpoint: signRecordsTable,
    body: encodedBody,
  );

  if (response.statusCode == 200) {
    var skyFlowId = response.data['records'][0]["skyflow_id"];

    sendFileToBackend(
        filename,
        bytes,
        blobUrl,
        skyFlowId,
        userId,
        userApplicationId,
        callback,
        isSuccessfull,
        resetFileInfo,
        showToast,
        requestname,
        recipientEmail,
        recipientName,
        resetCategory,
        resetSubCategory,
        resetTextField,
        fileReset,
        resetDropZone,
        resetSubCategoryDefault);

    return true;
  } else {
    print('Failed to create post. Status Code: ${response.statusCode}');
  }
}
