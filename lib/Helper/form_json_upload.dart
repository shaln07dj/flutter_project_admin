import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<void> formJsonUpload({
  var file,
  // required Function callback,
  required Function isSuccessfull,
  required Function resetFileInfo,
  required Function(String message) showToast,
  required Function(bool status) resetCategory,
  required Function(bool status) resetSubCategory,
  required Function resetTextField,
  required Function(bool status) fileReset,
  required Function resetDropZone,
  required Function resetSubCategoryDefault,
}) async {
  var jsonContent = utf8.decode(file);
  var jsonData = json.decode(jsonContent);

  String? firebaseToken = await getFirebaseIdToken();

  var streamedResponse = await makeNetworkRequest(
    "POST",
    firebaseToken!,
    baseUrl,
    subUrl: subUrl,
    endpoint: createForm,
    body: jsonData,
  );

  // debugPrint("streamedResponse type: ${streamedResponse.runtimeType}");
  debugPrint(
      "streamedResponse type: ${streamedResponse.data['formTemplates']}");

  // streamedResponse.statusCode = 401;
  if (streamedResponse.statusCode == 201) {
    debugPrint("Inside IF 201");
    isSuccessfull();
    showToast(jsonUploadMsg);
    resetSubCategory(true);
    resetSubCategoryDefault();
    resetCategory(true);
    resetTextField();
    resetDropZone();
    resetFileInfo();
    debugPrint("Inside IF Bottom 201");
  } else {
    debugPrint('Failed to upload file.');
    showToast(jsonFailMsg);
    resetSubCategory(true);
    resetSubCategoryDefault();
    resetCategory(true);
    resetTextField();
    resetDropZone();
    resetFileInfo();
  }
}
