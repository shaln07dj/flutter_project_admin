import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfData;

  const PdfViewerScreen({Key? key, required this.pdfData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(50),
      width: screenWidth*0.05,
      height: screenHeight*0.05,
      child: Center(
        child: SfPdfViewer.memory(
          pdfData,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            // Handle document loading completion if needed
          },
        ),
      ),
    );
  }
}
