import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';

class FileWebView extends StatefulWidget {
  const FileWebView(this.recordId, {super.key});
  final String recordId;
  @override
  _FileWebViewState createState() => _FileWebViewState(recordId);
}

class _FileWebViewState extends State<FileWebView> {
  final String containerId = 'myDartHtmlContainer';
  final String recordId;
  _FileWebViewState(this.recordId);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      String? firetoken = await getFirebaseIdToken();

      js.context.callMethod('renderFile', [
        firetoken,
        recordId,
        vaultId,
        "https://$skyFlowBaseUrl",
        fileRecordsTable,
        "https://$baseUrl$subUrl/$tokenEndPoint"
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  @override
  void dispose() {
    js.context.callMethod('removeElement', []);
    super.dispose();
  }
}
