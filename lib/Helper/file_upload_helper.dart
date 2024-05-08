import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/create_document_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future<void> sendFileToBackend(
    String filename,
    String bytes,
    String? blobUrl,
    String skyFlowId,
    String userId,
    String applicationId,
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
  final response = await http.get(Uri.parse(blobUrl!));
  final String token = await getSkyFlowToken() ?? '';

  if (response.statusCode == 200) {
    Response streamedResponse = await makeNetworkRequest(
      "MULTIPART_POST",
      token,
      skyFlowBaseUrl,
      subUrl: sfSubUrl,
      vaultId: vaultId,
      tableName: signRecordsTable,
      skyflowId: skyFlowId,
      endpoint: files,
      blobUrl: blobUrl,
      fileName: filename,
    );

    if (streamedResponse.statusCode == 200) {
      callback();
      isSuccessfull();
      resetFileInfo();
      showToast(fileUploadMsg);

      createDocument('signing_request', recipientEmail, recipientName,
          skyFlowId, applicationId, userId);
    } else {
      debugPrint('Failed to upload file.');
    }
  } else {
    debugPrint(
        'Failed to fetch the file from the Blob URL. Error: ${response.reasonPhrase}');
  }
}
