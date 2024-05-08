import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_user_phone_helper.dart';
import 'package:pauzible_app/Helper/send_email_sms_helper.dart';
import 'package:pauzible_app/api/skyflow/widgets/interceptor.dart';

Future createDocument(requestName, recipientEmail, recipientName, skyFlowId,
    applicationId, userId) async {
  var b = {
    "request_name": requestName,
    "recipient_email": recipientEmail,
    "recipient_name": recipientName,
    "record_id": skyFlowId,
    "application_id": applicationId
  };
  var c = jsonEncode(b);
  final String token = await getSkyFlowToken() ?? '';

  Response response = await makeNetworkRequest("POST", token, baseUrl,
      subUrl: subUrl, endpoint: createDoc, body: c);

  if (response.statusCode == 200) {
    print('Document created successfully.');
    // add the send email mechanism here to send email to user...
    String? firebaseToken = await getFirebaseIdToken();

    var userPhone = await getUserPhone(userId);
    sendEmailSMS(firebaseToken!, "adminDocumentUpload", recipientEmail,
        skyFlowId, userPhone);
  } else {
    print('Failed to create document. Status Code: ${response.statusCode}');
  }
}
